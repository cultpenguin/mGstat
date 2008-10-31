      subroutine cov_vol2vol(ivol1,ivol2,vvcov)
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
c     Returns the covariance between to volume, ivol1 and ivol2
c     in case volume average data is present
c     *********************************************
c     
c     INPUT VARIABLES:
c     
c     ivol1        number of volume 1
c     ivol2        number of volume 2 
c     
c     OUTPUT VARIABLES:
c     
c     vvcov       volume to voume covariance 
c     
c     ORIGINAL : Thomas Mejer Hansen                       DATE: June 2004
c
c     TODO : Use either lookup table in RAM or a lookup table on disk 
c
c-----------------------------------------------------------------------
      include 'visim.inc'
      real vvcov
      integer i,j,k,ivol_temp
      real x1,x2,y1,y2,z1,z2
      real cov
      
      if ((ivol1.eq.0).AND.(ivol2.eq.0)) then
         if (idbg.gt.0) then 
            write(*,*) 'Initializing vol2vol covar lookup table' 
         endif
         k=0
         do i=1,MAXVOLS
            do j=1,MAXVOLS
               cv2v(i,j)=UNEST
            enddo
         enddo
        vvcov=0
        return
      endif
 
c     UNCOMMENT NEXT LINE TO NOT USE LOOKUP TABLE
c      cv2v(ivol1,ivol2)=UNEST

      if (cv2v(ivol1,ivol2).eq.UNEST) then
         vvcov=0
         do i=1,ndatainvol(ivol1)
            do j=1,ndatainvol(ivol2)
               x1=volx(ivol1,i)
               y1=voly(ivol1,i)
               z1=volz(ivol1,i)
               x2=volx(ivol2,j)
               y2=voly(ivol2,j)
               z2=volz(ivol2,j)
               
               call cova3(x1,y1,z1,
     +              x2,y2,z2,1,nst,MAXNST,c0,it,
     +              cc,aa,1,MAXROT,rotmat,cmax,cov)
               
               vvcov=vvcov + 
     +              dble(cov)*( voll(ivol1,i) * voll(ivol2,j) )
               
            enddo
         enddo
c     PUT VALUE IN LOOKUP TABLE
         cv2v(ivol1,ivol2) =  dble(vvcov )
      else         
         vvcov = dble(cv2v(ivol1,ivol2))
      endif

      return 
      end
      
