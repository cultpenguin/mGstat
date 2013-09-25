      subroutine create_condtab()
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C                                                                      %
C Copyright (C) 1996, The Board of Trustees of the Leland Stanford     %
C Junior University.  All rights reserved.                             %
C                                                                      %
C The programs in GSLIB are distributed in the hope that they will be  %
C useful, but WITHOUT ANY WARRANTY.  No author or distributor accepts  %
C responsibility to anyone for the consequences of using them or for   %
C whether they serve any particular purpose or work at all, unless he  %
C says so in writing.  Everyone is granted permission to copy, modify  %
C and redistribute the programs in GSLIB, but only under the condition %
C that this notice and the above copyright notice remain intact.       %
C                                                                      %
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c-----------------------------------------------------------------------
c     
c     Builds a lookup table forthe local shape of the 
c     conditional probaility.
c     See Oz et. al 2003 or Deutch 2000, for details.
c     *********************************************
c     
c     INPUT VARIABLES:
c     
c     OUTPUT VARIABLES:
c     
c     condtab : conditoinal prob lookup table 
c     
c     ORIGINAL : Thomas Mejer Hansen                       DATE: August 2005
c
c
c     DISCRETE = 1
c
c-----------------------------------------------------------------------
c      implicit none
      use geostat_allocate
	  include 'visim.inc'
      integer i,j,k,im,iv,i_monte
      real Gmean,gGvar
      real sum_sim,sum_sim2
      real mean_sim, var_sim
      real p,zt,ierr,simu
      real arr(20)
      real target(nbt)
      real target_nscore(nbt)
      real target_nscore_center(nbt)
      real target_p(nbt), temp(nbt)
      real target_weight(nbt)
      integer itarget_quan
c      real zmin,zmax
      real ierror
      
      real q_norm, q_back(599) 
      real x_cpdf(1500) 
      real backtrans
      integer index_cdf
      character tmpfl*80
      real te
      real*8 dummy1,dummy2,draw,draw_l,draw_h

      integer GmeanType,GvarType

      GmeanType=0
      GvarType=0

      do i=1,nbt
         target(i)=bootvar(i);
c     NEXT LINE TO MAKE SURE ALLE DATA HAVE WEIGHT 1... 
c     THERE IS PROBABLY A BUG IN THE visim_readpar_uncertainty.f file here
c     AS bootvar is NOT 1 when it has to be..
         target_weight(i)=1;
c         write(*,*) i,target(i),target_weight(i)
      enddo

C
C SHOULD WE USE TAIL AT ALL WHEN USING DSSIM ?
c
c
c AUTOMATICALLY SET NUMBER OF BINS TO THE NUMBER OF USED DATA WHEN discrete=1;




c
c     Compute Normal Score of TARGET HISTOGRAM
c
      call nscore(nbt,target,zmin,zmax,0,target_weight,temp,1,
     1     target_nscore,ierror,discrete)
c     centere normal scores 
      call nscore(nbt,target,zmin,zmax,0,target_weight,temp,1,
     1     target_nscore_center,ierror,0)


c     WRITING NSCORE TABLE TO FILE
      tmpfl='nscore'//'_'//outfl

      open(39, file=tmpfl, status = 'unknown')
      do i=1,nbt
         write(39,*) target(i),target_nscore(i),target_nscore_center(i),
     1        target_weight(i),zmin,zmax
      enddo



C OLD METHOD PRE 2010
c      do i=1,n_q
c         x_quan(i)=(1./n_q)/2+(i-1)*(1./n_q)
c      enddo
c NEW METHOD POST 2010
      
      if (discrete.eq.1) then
         do i=1,(n_q)
            x_quan(i)=(i)*(1./n_q)
         enddo
      else
         do i=1,(n_q)
c BETTER HIST REPRODUCTION            
c            x_quan(i)=(i-1)*(1./n_q) + (1./n_q)/2
            x_quan(i)=(i-1)*(1./(n_q-1))
         enddo 
      endif

      do i=1,(n_q)
         x_quan_center(i)=(i-1)*(1./n_q) + (1./n_q)/2
      enddo 

      if (idbg.gt.0) then 
         write(*,*) ' Nscore MEAN range=',min_Gmean,max_Gmean,n_Gmean
         write(*,*) ' Nscore VAR range = ',min_Gvar, max_Gvar, n_Gvar
         write(*,*) ' Number of quantiles = ',n_q
         write(*,*) ' Number of samples drawn in nscore space= ',n_monte
         write(*,*) 'Calc CondPDF Lookup n_Gmean,n_Gvar=',n_Gmean,n_Gvar 
      endif

      do im=1,n_Gmean

         Gmean=min_Gmean+(im-1)*(max_Gmean-min_Gmean)/(n_Gmean-1)            
         
         if (idbg.ge.2) write(*,*) 'precalc lookup im,n_Gmean=',
     1        im,n_Gmean, Gmean

         do iv=1,n_Gvar

            gGvar=min_Gvar+(iv-1)*(max_Gvar-min_Gvar)/(n_Gvar-1)

            if (iv.eq.1) gGvar=min_Gvar

c     BACK TRANSFORM QUANTILES
            dummy1=0
            dummy2=0
            do i=1,n_q
               call gauinv(dble(x_quan_center(i)) ,zt,ierr)
               q_norm=zt*sqrt(gGvar)+Gmean            

              x_cpdf(i) = backtr(q_norm,nbt,target,target_nscore_center,
     +              zmin,zmax,ltail,ltpar,utail,utpar,discrete)

               dummy1 = dummy1 + x_cpdf(i)
               dummy2 = dummy2 + x_cpdf(i)*x_cpdf(i)

            enddo
            dummy1 = dummy1 / n_q
            dummy2 = dummy2 / n_q
            dummy2 = dummy2 - dummy1*dummy1

            mean_sim=dummy1
            var_sim=dummy2

            if (var_sim.lt.0) var_sim=0

            condlookup_mean(im,iv)=mean_sim
            condlookup_var(im,iv)=var_sim
            do i=1,n_q
               condlookup_cpdf( im,iv,i) = x_cpdf(i)
            enddo

         if (idbg.gt.2) write(*,*) 'gm,gv,mean_sim,mean_var',
     1        Gmean,gGvar,mean_sim,var_sim
            
      enddo
     
      enddo


c     wirte lookup tables to disk      
      if (idbg.gt.0) then 
         
         tmpfl='cond_imean'//'_'//outfl
         open(29, file=tmpfl, status = 'unknown')
         tmpfl='cond_mean'//'_'//outfl
         open(30, file=tmpfl, status = 'unknown')
         tmpfl='cond_var'//'_'//outfl
         open(31, file=tmpfl, status = 'unknown')
         tmpfl='cond_cpdf'//'_'//outfl
         open(32, file=tmpfl, status = 'unknown')
         do im=1,n_Gmean
            do iv=1,n_Gvar
               write(29,*) im
               write(30,*) condlookup_mean(im,iv)
               write(31,*) condlookup_var(im,iv)
               if (idbg.gt.0) then
                  do i=1,n_q
                     write(32,*) condlookup_cpdf(im,iv,i)
                  enddo
               endif
            enddo     
         enddo
         close(30)
         close(31)
         close(32)         
      endif

      return

      end
      


      real function drawfrom_condtab(cmean,cvar,p)
c-----------------------------------------------------------------------
c     
c     Draw from a lookup table for the local shape of the 
c     conditional probaility.
c     See Oz et. al 2003 or Deutch 2000, for details.
c     *********************************************
c     
c     INPUT VARIABLES:
c     
c     OUTPUT VARIABLES:
c     
c     condtab : conditoinal prob llokup table 
c     
c     ORIGINAL : Thomas Mejer Hansen                       DATE: August 2005
c     
c
c-----------------------------------------------------------------------
c      implicit none
	  use geostat_allocate
      include 'visim.inc'
      real cmean, cvar
      integer im,iv,iq,ie,is,xid
      real cmean_arr(500), i_arr(500)
      real i_mean(500), mean(500)
      real dist
      real mindist
      integer im_sel, iv_sel
      real m_sel, v_sel
      real p
      integer index_cdf
      real Kmean, Kstd, Fmean, Fstd, draw
      cvar=cvar*cvar
            

c     NEXT TMH
      dm=xmax-xmin;
c     NEXT OZ
      dm=skgmean
      dv=gvar

      
      mindist=1e+9
      do im=1,n_Gmean
         do iv=1,n_Gvar


C     TMH STYLE
c     BUT TOO HIGH SILL VALUE
c            dist=( (condlookup_mean(im,iv)-cmean)/dm )**2+
c     +        ( (condlookup_var(im,iv)-cvar)/dv )**2            
C     OZ STYLE            
C     WORSE MATCH TO HISTOGRAM THAN ABOVE
            dist=( (condlookup_mean(im,iv)-cmean)/dm )**2+
     +        abs (condlookup_var(im,iv)-cvar)/sqrt(dv)             

            
            if (dist.lt.mindist) then
               mindist=dist
               im_sel=im
               iv_sel=iv
            endif
         enddo
      enddo

      m_sel = condlookup_mean(im_sel,iv_sel)
      v_sel = condlookup_var(im_sel,iv_sel)

      if (idbg.gt.2) then
	write(*,*) '-- looking up in condtab'
        write(*,*) 'cmean,cvar=',cmean,' ',cvar
	write(*,*) 'm_sel=',m_sel,im_sel
	write(*,*) 'v_sel=',v_sel,iv_sel
      endif


c     CHANGED FROM lout_krig=59, on Nov 9, 2009 by TMH
      lout_krig=60
      write(lout_krig,86) cmean, cvar,m_sel,v_sel
 86   format(f12.6,f15.9,f12.6,f15.9)  
      


c     NOW DRAW FROM LOCAL CPDF
c     (ARE THE FIRST TENS OF RESULTS FROM acorni2 CORRELATED 
c      do i=1,101
c         p = acorni2(idum) 
c      enddo

c select random quantile
      p = acorni2(idum) 


c locate quantile      
      do i=1,(n_q);
         if (x_quan(i).gt.p) then
            index_cdf=i
            exit
         endif
         
      enddo

      if (p.gt.x_quan(n_q)) then
         index_cdf=n_q
      endif

      if (discrete.eq.1) then
c     FIND ARRAY
         write(*,*) 'DEBUG7 PRE',im_sel, iv_sel,index_cdf
         draw = condlookup_cpdf(im_sel,iv_sel,index_cdf) 
         write(*,*) 'DEBUG7 PRO, draw=',draw
 
      else
c      ASSUME CONTINIOUS TARGET HISTOGRAM
         
c interpolate
         draw_h = condlookup_cpdf(im_sel,iv_sel,index_cdf) 
         draw_l = condlookup_cpdf(im_sel,iv_sel,index_cdf-1) 
         
         h=x_quan(index_cdf)-x_quan(index_cdf-1)
         draw_a = draw_h*(x_quan(index_cdf)-p)/h 
         draw_b = draw_l*(p-x_quan(index_cdf-1))/h 

         draw = draw_a + draw_b

c handle tails
         if (p.lt.x_quan(1)) then
            draw=condlookup_cpdf(im_sel,iv_sel,1)
         endif
         if (p.gt.x_quan(n_q)) then
            draw=condlookup_cpdf(im_sel,iv_sel,n_q)
         endif
      endif



c      index_cdf = 1 + int(p*n_q)

      drawfrom_condtab = draw


      write(*,*) 'DEBUG8 draw=',drawfrom_condtab
         

c     CORRECTION ACCORDING TO Oz et al, 2003
c     Consider another correction that builds a differet
c     local cpdf based on closeness to lookup table
      doOzCorr=0
      if (doOzCorr.eq.1) then
        Fmean = condlookup_mean(im_sel,iv_sel)
        Fstd = sqrt( condlookup_var(im_sel,iv_sel) )

        Kmean= cmean
        Kstd = sqrt(cvar)

        if (Fstd.lt.(0.00001)) then
           write(*,*) 'draw=',drawfrom_condtab,Fmean,Fstd,
     1          Kmean,Kstd
        endif
      
        drawfrom_condtab = ( draw - Fmean ) * ( Kstd / Fstd) + Kmean

        if (Fstd.lt.(0.00001)) then
           write(*,*) 'draw=',drawfrom_condtab,Fmean,Fstd,
     1          Kmean,Kstd
           stop
        endif

      endif

      write(*,*) 'DEBUG8 draw=',drawfrom_condtab
            

      return 
      

      end
      
