      subroutine krige_volume(ix,iy,iz,xx,yy,zz,lktype,
     +     gmean,cmean,cstdev,sim_index)
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
c     Builds and Solves the SK Kriging System
c     in case volume average data is present
c     *********************************************
c     
c     INPUT VARIABLES:
c     
c     ix,iy,iz        index of the point currently being simulated
c     xx,yy,zz        location of the point currently being simulated
c     sim_index       index of point being simulated
c     
c     
c     OUTPUT VARIABLES:
c     
c     cmean           kriged estimate
c     cstdev          kriged standard deviation
c     
c     
c     
c     EXTERNAL REFERENCES: ksol   Gaussian elimination system solution
c     
c     
c     Consider implementing Kriging with a locally varying mean and OK
c     Make volobs_ref a global variable (right now calculated in each ite)
c     volobs_ref could be read from..
c
c
c
c
c
c     
c     ORIGINAL: C.V. Deutsch                               DATE: August 1990
c     REVISION : Thomas Mejer Hansen                       DATE: June 2004
c     including volume average data
c-----------------------------------------------------------------------
      include 'visim.inc'
      logical first
      real	spos(MAXKR1)
      real covsum
      real rdummy
      integer na,in,index
      integer iv1,iv2
      integer iray1, iray2,volindex
      integer sim_index
      integer neq_read
      real vvcov

      if (lktype.ne.0) then
         write (*,*) 'VISIM CURRENTLY ONLY WORKS FOR SIMPLE KRIGING'
         stop
      end if

      
c     
c     calculate reference volume averages
c     
c      nusev=0


      
C c     MAKE VOLOBS_REF A GLOBAL VARIABLE !!!!
C       if (nusev.gt.0) then
C       do i=1,nvol
C          volobs_ref(i)=0;
C          do j=1,nvol
C                volobs_ref(i) = 
C      +           volobs_ref(i) + voll(i,j)*gmean
C          enddo
C       enddo
C       endif
         

c     
c     Size of the kriging system:
c     
      
C     NUMBER OF CONDITIONAL DATA
      first = .false.
      na    = nclose + ncnode
      
      if (idbg.gt.3) then
         write (*,*) '***********'
         write(*,*) 'nclose, ncnode= ',nclose,ncnode
         do j=1,na
            if(j.le.nclose) then
               index  = int(close(i))
            else
               index  = j-nclose
            endif
            write (*,*) 'na=',na,' j=',j,' index=',index
         enddo
      endif
      
c      write(*,*) 'nusev=',nusev,MAXVOLS,' na=',na


C     NUMBER OF EQUATIONS
      neq = na + nusev
      if(idbg.ge.11) then
         write(*,*) 'Using na=',na,' nusev=',nusev,
     +        ' nclose, ncnode= ',nclose,ncnode
      endif

ccc      write(*,*) na,'  ',nusev
c     
c     Set up kriging matrices:
c     
      in=0
      do j=1,na
c     
c     Sort out the actual location of point "j"
c     
         if(j.le.nclose) then
            index  = int(close(j))
            x1     = x(index)
            y1     = y(index)
            z1     = z(index)
            vra(j) = vr(index)
            vrea(j)= sec(index)
         else
c     
c     It is a previously simulated node (keep index for table look-up):
c     
            index  = j-nclose
            x1     = cnodex(index)
            y1     = cnodey(index)
            z1     = cnodez(index)
            vra(j) = cnodev(index)
            ind    = icnode(index)
            ix1    = ix + (int(ixnode(ind))-nctx-1)
            iy1    = iy + (int(iynode(ind))-ncty-1)
            iz1    = iz + (int(iznode(ind))-nctz-1)
            index  = ix1 + (iy1-1)*nx + (iz1-1)*nxy
            vrea(j)= lvm(index)
         endif
         do i=1,j
c     
c     Sort out the actual location of point "i"
c     
            
            if(i.le.nclose) then
               index  = int(close(i))
               x2     = x(index)
               y2     = y(index)
               z2     = z(index)
            else
c     
c     It is a previously simulated node (keep index for table look-up):
c     
               index  = i-nclose
               x2     = cnodex(index)
               y2     = cnodey(index)
               z2     = cnodez(index)
               ind    = icnode(index)
               ix2    = ix + (int(ixnode(ind))-nctx-1)
               iy2    = iy + (int(iynode(ind))-ncty-1)
               iz2    = iz + (int(iznode(ind))-nctz-1)
            endif
c     
c     Now, get the covariance value:
c     
            in = in + 1

            call cova3(x1,y1,z1,x2,y2,z2,1,nst,MAXNST,
     +           c0,it,cc,aa,1,MAXROT,rotmat,cmax,cov)
            a(in) = dble(cov)

            if (i.eq.j) then
c                  This where oné should add uncertainty of POINT DATA
c                  write(*,*) 'a(',in,')=',a(in)
c                  a(in)=a(in)+0.1
            endif

         end do
c     
c     Get the RHS value (possibly with covariance look-up table):
c     
         call cova3(xx,yy,zz,x1,y1,z1,1,nst,MAXNST,c0,it,
     +        cc,aa,1,MAXROT,rotmat,cmax,cov)
         r(j) = dble(cov)
         rr(j) = r(j)

         
      end do 
c     ENDED LOOPING OVER DATA i


      if (nusev.gt.0) then 
c     write(*,*) 'setting up kriging system for volume data'
         do iv1=1,nusev
            iray1=usev(iv1)

c     SETUP UNKNOWN TO VOLUME
            call cov_data2vol(sim_index,xx,yy,zz,iray1,vvcov)
            r(na+iv1)=dble(vvcov)
            rr(na+iv1)=dble(vvcov)



c     SETUP VOLUME TO DATA
c     A lookup table should be considered. to increase performance !!!
c            write(*,*) 'VOL2DATA  ----'
            do index=1,na

               x1     = cnodex(index)
               y1     = cnodey(index)
               z1     = cnodez(index)
               in=in+1

               call cov_data2vol(cnodeindex(index),x1,y1,z1,iray1,vvcov)

               a(in)=dble(vvcov)
            enddo
            

c     SETUP VOLUME TO VOLUME
c            write(*,*) 'VOL2VOL ----'
            do iv2=1,iv1
               in=in+1
               iray2=usev(iv2)
               call cov_vol2vol(iray1,iray2,vvcov)
               a(in)=dble(vvcov) + datacov(iray1,iray2)
               if(idbg.ge.3) then
                  write(*,*) 'a,in,iray1,iray2,datacov,vvcov=',
     +                 a(in),in,iray1,iray2,datacov(iray1,iray2),
     +                 vvcov
               endif

c               a(in)=dble(vvcov)
c               if (iray1.eq.iray2) then
c                  a(in)=a(in)+volvar(iray1)
c               endif
c               write(*,*) 'a,in,iray1,iray2=',
c     +              a(in),in,iray1,iray2,datacov(iray1,iray2)


            enddo 
         enddo
      endif



c     
c Write out the kriging Matrix if Seriously Debugging:
c

         

      if(idbg.ge.3) then
            write(ldbg,100) ix,iy,iz
c            write(*,100) ix,iy,iz
            is = 1
            do i=1,neq
                  ie = is + i - 1
                  write(ldbg,101) i,r(i),(a(j),j=is,ie)
                  write(*,101) i,r(i),(a(j),j=is,ie)
                  is = is + i
               end do
 100        format(/,'Kriging Matrices for Node: ',3i4,' RHS first')
 101        format('   ! r(',i2,') = ',f12.8,'  a= ',99f13.8,' ')
         endif



c     
c     Solve the Kriging System:
c     

         if (read_lambda.eq.1) then
c     reads lambda from file
c     do NOT compute lambda
            read(99) neq_read
            read(99) ising
            read(99) (s(i),i=1,neq)
         else 
         
            if(neq.eq.1.and.lktype.ne.3) then
               s(1)  = r(1) / a(1)
               ising = 0
            else
               call ksol(1,neq,1,a,r,s,ising)
            endif
         endif
            

         if (read_lambda.eq.0) then
            write(99) (neq)
            write(99) (ising)
            write(99) (s(i),i=1,neq)
         endif
            

         if (idbg.ge.4) then 
            do i=1,na
               write(*,140) i,vra(i),s(i)
            enddo
            do i=1,nusev
               write(*,140) i+na,volobs(usev(i)),s(i+na)
            enddo
         endif


c Write a warning if the matrix is singular:
c
      if(ising.ne.0) then
            if(idbg.ge.1) then
                  write(*,*) 'WARNING : singular matrix'
                  write(*,*) '          for node',ix,iy,iz,sim_index
                  write(*,*) 'ASSIGNING GLOBAL MEAN AND VAR !!!!' 
                  write(*,*) '**********************************' 
            endif
            write(*,*) 'Singular Matrix   sim_index=',sim_index 
            cmean  = gmean
            cstdev = sqrt(gvar)
            return
      endif
c
c Compute the estimate and kriging variance.  Recall that kriging type
c     0 = Simple Kriging:
c     1 = Ordinary Kriging:
c     2 = Locally Varying Mean:
c     3 = External Drift:
c     4 = Collocated Cosimulation:
c

      
C     ccb is the the unknown data variance
      cmean  = 0.0
c      write(*,*) 'cbb=',cbb,sqrt(cbb)
      cstdev = cbb
      sumwts = 0.0
      do i=1,na
         rdummy=(vra(i)-gmean)
         cmean  = cmean  + real(s(i))*rdummy
         cstdev = cstdev - real(s(i)*rr(i))
         sumwts = sumwts + real(s(i))
         if (idbg.ge.4) then
            write(*,*) 'A CMEAN=',i,cmean,cstdev,s(i),
     +              ' r=',r(i),' rr=',rr(i)
         endif
      end do


      if (nusev.gt.0) then
         do i=1,nusev
           
            rdummy=(volobs(usev(i))-volobs_ref(usev(i)))

            cmean  = cmean  + real(s(i+na))*rdummy
            cstdev = cstdev - real(s(i+na)*rr(i+na))
            sumwts = sumwts + real(s(i+na))
            if (idbg.ge.4) then
             write(*,*) 'B CMEAN, s=',s(i+na)
             write(*,*) 'B CMEAN, volobs(usev(i))=',volobs(usev(i)),
     +              'r=',r(i+na),' rr=',rr(i+na)
             write(*,*) 'B CMEAN, volobs_ref(ray)=',volobs_ref(usev(i))
             write(*,*) 'B CMEAN, v_obs-v0=',rdummy
             write(*,*) 'B CMEAN, WEIGHT=',s(i+na)
             write(*,*) 'B CMEAN, (v_obs-v0)*W=',rdummy*s(i+na)
             write(*,*) 'B CMEAN=',cmean,cstdev,s(i+na),volobs(i),
     +              real(s(i+na))*(volobs(i)-volobs_ref(usev(i)))
             write(*,*) '--'
            endif
         end do
      endif

      
      if(lktype.eq.0) cmean = gmean + cmean


c     
c     Error message if negative variance:
c     
      if(cstdev.lt.0.0) then
         write(ldbg,*) 'ERROR: Negative Variance: ',cstdev
         cstdev = 0.0
      endif
      


c TO GET STANDARD DEVIAION TAKE SQRT(VAR)
c     

      cstdev = sqrt(cstdev)
    
c     
c     Write out the kriging Weights if Seriously Debugging:
c
        
      if(idbg.ge.1113) then
         write(*,*) 'DEBIGGGGGGGGGGGGGGGGGGGGg'
         do i=1,na
            write(ldbg,140) i,vra(i),s(i)
            write(*,140) i,vra(i),s(i)
         end do
         do i=1,nusev
            write(ldbg,140) na+i,vra(i),s(i)
            write(*,140) i+na,volobs(usev(i)),s(na+i)
         end do


 140     format(' Data ',i4,' value ',f12.4,' weight ',f12.4)
         if(lktype.eq.4) write(ldbg,141) lvm(ind),s(na+1)
 141     format(' Sec Data  value ',f12.4,' weight ',f12.4)
         write(ldbg,142) gmean,cmean,cstdev
         write(*,142) gmean,cmean,cstdev
 142     format(' Global mean ',f12.4,' conditional ',f12.4,
     +        ' std dev ',f12.4)
      end if
c     
c     Finished Here:
c
      
      return
      end
