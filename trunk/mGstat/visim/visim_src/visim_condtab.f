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
c-----------------------------------------------------------------------
c      implicit none
      include 'visim.inc'
      integer i,j,k,im,iv,i_monte
      real Gmean,gGvar
      real sum_sim,sum_sim2
      real mean_sim, var_sim
      real p,zt,ierr,simu
      real arr(20)
      real target(nbt), target_nscore(nbt)
      real target_p(nbt), temp(nbt)
      real target_weight(nbt)
      integer itarget_quan
c      real zmin,zmax
      real ierror
      
      real q_norm, q_back(599) 
      real x_cpdf(500) 
      real backtrans
      integer index_cdf
      character tmpfl*80
      real te
      real*8 dummy1,dummy2

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


c
c     Compute Normal Score of TARGET HISTOGRAM
c
      if (idbg.gt.0) then 
         write(*,*) 'zmin=',zmin
         write(*,*) 'zmax=',zmax
         write(*,*) 'ltail=',ltail,ltpar
         write(*,*) 'utail=',utail,utpar
      endif 

      call nscore(nbt,target,zmin,zmax,0,target_weight,temp,1,
     1     target_nscore,ierror)

c     WRITING NSCORE TABLE TO FILE
      write(tmpfl,771) 'nscore',outfl
      open(39, file=tmpfl, status = 'unknown')
      do i=1,nbt
         write(39,*) target(i),target_nscore(i),target_weight(i),
     1        zmin,zmax
      enddo


      do i=1,n_q
         x_quan(i)=(1./n_q)/2+(i-1)*(1./n_q)
      enddo


      if (idbg.gt.0) then 
         write(*,*) ' Nscore MEAN range=',min_Gmean,max_Gmean,n_Gmean
         write(*,*) ' Nscore VAR range = ',min_Gvar, max_Gvar, n_Gvar
         write(*,*) ' Number of quantiles = ',n_q
         write(*,*) ' Number of samples drawn in nscore space = ',n_monte
         write(*,*) 'Calc CondPDF Lookup n_Gmean,n_Gvar=',n_Gmean,n_Gvar 
      endif

      do im=1,n_Gmean

         if (GmeanType.eq.1) then 
c     Focus on middle range mean
            if (im.lt.(n_Gmean/2)) then
               Gmean = min_Gmean + 0.5*(max_Gmean-min_Gmean)*
     1              (1- exp(-1.0*im/(n_Gmean/20)) )
            else
               Gmean = min_Gmean+ 0.5*(max_Gmean-min_Gmean) +
     1              0.5*(max_Gmean-min_Gmean)*
     1              (1-(1-exp(-1.0*(n_Gmean-im)/(n_Gmean/20)) ))
            endif
         else
c     linear mean range
            Gmean=min_Gmean+(im-1)*(max_Gmean-min_Gmean)/(n_Gmean-1)            
         endif

         if (idbg.gt.2) write(*,*) 'precalc lookup im,n_Gmean=',
     1        im,n_Gmean

         do iv=1,n_Gvar

            if (GvarType.eq.1) then 
c Cosine, focus on low variances
               gGvar = min_Gvar + 
     1              (max_Gvar-minGvar)*(1-cos(.5*iv*3.14/n_Gvar))
            elseif (GvarType.eq.2) then
c Cosine, focus on high variances
               gGvar = min_Gvar + 
     1              (max_Gvar-minGvar)*(cos(.5*iv*3.14/n_Gvar))
            else
c     Linear 
               gGvar=min_Gvar+(iv-1)*(max_Gvar-min_Gvar)/(n_Gvar-1)
            endif
            if (iv.eq.1) gGvar=min_Gvar
c     BACK TRANSFORM QUANTILES
            dummy1=0
            dummy2=0
            do i=1,n_q
c               x_quan(i)=(1./n_q)/2+(i-1)*(1./n_q)
               call gauinv(dble(x_quan(i)) ,zt,ierr)
               q_norm=zt*sqrt(gGvar)+Gmean            

               x_cpdf(i) = backtr(q_norm,nbt,target,target_nscore,
     +              zmin,zmax,ltail,ltpar,utail,utpar,discrete)

c		write(*,*) 'xcpdf(i)=',i,x_cpdf(i)

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
         write(tmpfl,771) 'cond_imean',outfl
         open(29, file=tmpfl, status = 'unknown')
         write(tmpfl,771) 'cond_mean',outfl
         open(30, file=tmpfl, status = 'unknown')
         write(tmpfl,771) 'cond_var',outfl
         open(31, file=tmpfl, status = 'unknown')
         write(tmpfl,771) 'cond_cpdf',outfl
         open(32, file=tmpfl, status = 'unknown')
 771     format(A,'_',A)
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

c      write(*,*) 'gmean=',gmean
      
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
     +        abs (condlookup_var(im,iv)-cvar)/dv             

            
            if (dist.lt.mindist) then
               mindist=dist
               im_sel=im
               iv_sel=iv
            endif
         enddo
      enddo

      m_sel = condlookup_mean(im_sel,iv_sel)
      v_sel = condlookup_var(im_sel,iv_sel)

c	write(*,*) '-'
c	write(*,*) 'm_sel=',m_sel
c	write(*,*) 'v_sel=',v_sel

      lout_krig=59
      write(lout_krig,86) cmean, cvar,m_sel,v_sel
 86   format(f12.6,f15.9,f12.6,f15.9)  
      
      


c     NOW DRAW FROM LOCAL CPDF

c     MAKE SURE THAT QUANTILE IS WITHIN BOUNDS
      do i=1,10
c     NEXT LINE COMMENTED OUT ONCE - WHY 
         p = acorni2(idum) 
         if ((p.gt.x_quan(1)).AND.(p.lt.x_quan(n_q))) then
            exit
         else
            if (idbg.gt.1) then
           write(*,*) 'QUANTILE OUTSIDE RANGE',i,p,x_quan(1),x_quan(n_q)
            endif
         endif
      enddo

      if (p .le. x_quan(1)) then
         index_cdf = 1
         write(*,*)'bad low quantile',p,x_quan(1)
      else if (p .gt. x_quan(n_q)) then
         index_cdf = n_q
         write(*,*)'bad high quantile',p,x_quan(n_q)
      else
         call locate(x_quan,n_q,1,n_q,p,index_cdf)
      endif

c      index_cdf = 1 + int(p*n_q)
      draw = condlookup_cpdf(im_sel,iv_sel,index_cdf) 
c      write(*,*) 'INDEX ME',im_sel,iv_sel,index_cdf


      drawfrom_condtab = draw


c     CORRECTION ACCORDING TO Oz et al, 2003

      doOzCorr=0
      if (doOzCorr.eq.1) then
        Fmean = condlookup_mean(im_sel,iv_sel)
        Fstd = sqrt( condlookup_var(im_sel,iv_sel) )

        Kmean= cmean
        Kstd = sqrt(cvar)
      
        drawfrom_condtab = ( draw - Fmean ) * ( Kstd / Fstd) + Kmean
      endif


c      if (idbg.gt.14) then
      
      if (drawfrom_condtab.eq.(0.0000278)) then
         write(*,*) 'INDEX CDF = ',index_cdf
         write(*,*) 'cmean,cvar 2->',cmean,cvar
         write(*,*) 'im_sel,iv_sel -->',im_sel,iv_sel
         write(*,*) 'm_sel,v_sel -->',m_sel,v_sel
         write(*,*) 'Kmean,Kstd -->',Kmean,Kstd
         write(*,*) 'Fmean,Fstd -->',Fmean,Fstd
         write(*,*) 'Fmean,Fstd -->',drawfrom_condtab,draw
	endif
      



      return 


      end
      
