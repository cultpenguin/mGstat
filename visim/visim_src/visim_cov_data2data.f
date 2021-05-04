      subroutine cov_data2data(x1,y1,z1,x2,y2,z2,ddcov)
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
c     Returns the covariance between to data points
c     *********************************************
c     
c     INPUT VARIABLES:
c  
c     index        index of data point considered
c     x1,y1,z1     location of first data point
c     x2,y2,z2     location of second data point
c     
c     OUTPUT VARIABLES:
c     
c     ddcov       data to data covarianc
c     
c     ORIGINAL : Thomas Mejer nsen                       DATE: October 2004
c
c     TODO : Use either lookup table in RAM or a lookup table on disk 
c
c-----------------------------------------------------------------------
      include 'visim.inc'
      real ddcov
      integer i,j,k,ivol_temp,index
      integer ix1,iy1,iz1,ix2,iy2,iz2
      real x1,y1,z1,x2,y2,z2
      real cov
      
      if (x1.eq.0) then
         write(*,*) 'Initializing data2data covar lookup table' 
         k=0
         do i=1,(nx*ny*nz)
            do j=1,(nx*ny*nz)
               cd2d(i,j)=UNEST
            enddo
         enddo

         write(*,*) 'Initializing data2data covar lookup table' 
         ddcov=0
         return
      endif
      
c     ALL YOU NEED IS TO CALCULATE THE INDEXES
      index1=1
      index2=1
      
      index1 = ix1 + (iy1-1)*nx + (iz1-1)*nxy
      index1 = ix1 + (iy1-1)*nx + (iz1-1)*nxy

      if (cd2d(index1,index2).eq.UNEST) then

c         write(*,*) 'Initialize value'
c     CALCULATE THE VALUE


c         write (*,*) 'x1,y1,z1=',x1,y1,z1,x2,y2,z2
         call cova3(x1,y1,z1,
     +        x2,y2,z2,1,nst,MAXNST,c0,it,
     +        cc,aa,1,MAXROT,rotmat,cmax,cov)
         
         ddcov=dble(cov)
c     put the value inthe lookup table
c     comment this line out to disable the look table
c     in this case the cd2d variable should be removed from the visim.inc file.
         cd2d(index1,index2)=ddcov;
      else
         ddcov=cd2d(index1,index2);
         
      end if
      




      return

      end
      
