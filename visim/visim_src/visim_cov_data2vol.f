 3    subroutine cov_data2vol(index,x1,y1,z1,ivol,vvcov)
c-----------------------------------------------------------------------
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
c     
c     Returns the covariance between to volume, ivol1 and ivol2
c     in case volume average data is present
c     *********************************************
c     
c     INPUT VARIABLES:
c  
c     index        index of data point considered
c     x1,y1,z1     location of data point
c     ivol         volume number
c     ivol2        number of volume 2 
c     
c     OUTPUT VARIABLES:
c     
c     vvcov       volume to volume covariance 
c     
c     ORIGINAL : Thomas Mejer nsen                       DATE: June 2004
c
c     TODO : Use either lookup table in RAM or a lookup table on disk 
c
c-----------------------------------------------------------------------
      include 'visim.inc'
      real vvcov,ddcov
      integer i,j,k,ivol_temp,index
      integer ix,iy,iz
      real x1,x2,y1
      real cov
      
      if (ivol.eq.0) then
         if (idbg.gt.0) then 
            write(*,*) 'Initializing data2vol covar lookup table' 
         endif
         k=0
         do i=1,(nx*ny*nz)
            do j=1,MAXVOLS
               cd2v(i,j)=UNEST
            enddo
         enddo
         vvcov=0
         return
      endif

c     UNCOMMENT NEXT LINE TO NOT USE LOOKUP TABLE
c      cd2v(index,ivol)=UNEST

      if (cd2v(index,ivol).eq.UNEST) then
c     CALCULATE THE VALUE

c
c HERE THE TESTING TAKES PLACE !!!!!!
c


         covsum=0
         do i=1,ndatainvol(ivol) 
            call cova3(volx(ivol,i),voly(ivol,i),volz(ivol,i),
     +           x1,y1,z1,1,nst,MAXNST,c0,it,
     +           cc,aa,1,MAXROT,rotmat,cmax,cov)
c
            covsum=voll(ivol,i)*dble(cov)+covsum

c            call cov_data2data(volx(ivol,i),voly(ivol,i),volz(ivol,i),
c     +           x1,y1,z1,ddcov)
c            covsum=voll(ivol,i)*dble(ddcov)+covsum
c            write(*,*) 'INIT ',cov,covsum,voll(ivol,i),
c     1           x1,y1,z1,volx(ivol,i),voly(ivol,i),volz(ivol,i)

         enddo
c         write(*,*) '***'

         vvcov=covsum
c     put the value inthe lookup table
c     comment this line out to disable the look table
c     in this case the cd2v variable should be removed from the visim.inc file.
        cd2v(index,ivol)=vvcov;
      else
         vvcov=cd2v(index,ivol);         
      end if
      




      return

      end
      
