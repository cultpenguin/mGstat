      subroutine ctable
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
c               Establish the Covariance Look up Table
c               **************************************
c
c The idea is to establish a 3-D network that contains the covariance
c value for a range of grid node offsets that should be at as large
c as twice the search radius in each direction.  The reason it has to
c be twice as large as the search radius is because we want to use it
c to compute the data covariance matrix as well as the data-point
c covariance matrix.
c
c Secondly, we want to establish a search for nearby nodes that
c in order of closeness as defined by the variogram.
c
c
c
c INPUT VARIABLES:
c
c   xsiz,ysiz,zsiz  Definition of the grid being considered
c   MAXCTX,Y,Z      Number of blocks in covariance table
c
c   covariance table parameters
c
c
c
c OUTPUT VARIABLES:  covtab()         Covariance table
c
c EXTERNAL REFERENCES:
c
c   sqdist          Computes 3-D anisotropic squared distance
c   sortem          Sorts multiple arrays in ascending order
c   cova3           Computes the covariance according to a 3-D model
c
c
c
c-----------------------------------------------------------------------
      use geostat_allocate
	  parameter(TINY=1.0e-10)
      include  'visim.inc'
      real*8    hsqd,sqdist
      logical   first
c     
c     Size of the look-up table:
c     
      nctx = min(((MAXCTX-1)/2),(nx-1))
      ncty = min(((MAXCTY-1)/2),(ny-1))
      nctz = min(((MAXCTZ-1)/2),(nz-1))
c
c     Debugging output:
c     

      if (idbg.gt.-2) then
      write(ldbg,*)
      write(ldbg,*) 'Covariance Look up table and search for previously'
      write(ldbg,*) 'simulated grid nodes.  The maximum range in each '
      write(ldbg,*) 'coordinate direction for covariance look up is:'
      write(ldbg,*) '          X direction: ',nctx*xsiz
      write(ldbg,*) '          Y direction: ',ncty*ysiz
      write(ldbg,*) '          Z direction: ',nctz*zsiz
      write(ldbg,*) 'Node Values are not searched beyond this distance!'
      write(ldbg,*)
      endif

c     
c NOTE: If dynamically allocating memory, and if there is no shortage
c       it would a good idea to go at least as far as the radius and
c       twice that far if you wanted to be sure that all covariances
c       in the left hand covariance matrix are within the table look-up.
c
c Initialize the covariance subroutine and cbb at the same time:
c
      call cova3(0.0,0.0,0.0,0.0,0.0,0.0,1,nst,MAXNST,c0,it,cc,aa,
     +           1,MAXROT,rotmat,cmax,cbb)
c
c     Now, set up the table and keep track of the node offsets that are
c     within the search radius:
c     
      nlooku = 0
      do i=-nctx,nctx
         xx = i * xsiz
         ic = nctx + 1 + i
         do j=-ncty,ncty
            yy = j * ysiz
            jc = ncty + 1 + j
            do k=-nctz,nctz
               zz = k * zsiz
      kc = nctz + 1 + k
      call cova3(0.0,0.0,0.0,xx,yy,zz,1,nst,MAXNST,c0,it,cc,aa,
     +     1,MAXROT,rotmat,cmax,covtab(ic,jc,kc))
      hsqd = sqdist(0.0,0.0,0.0,xx,yy,zz,isrot,
     +     MAXROT,rotmat)
      if(real(hsqd).le.radsqd) then
         nlooku         = nlooku + 1
c     
c     We want to search by closest variogram distance (and use the
c     anisotropic Euclidean distance to break ties:
c     
         tmp(nlooku)   = - (covtab(ic,jc,kc)-TINY*real(hsqd))
         order(nlooku) = real((kc-1)*MAXCXY+(jc-1)*MAXCTX+ic)
      endif
      end do
      end do
      end do
c     
c     Finished setting up the look-up table, now order the nodes such
c     that the closest ones, according to variogram distance, are searched
c     first. Note: the "loc" array is used because I didn't want to make
c     special allowance for 2 byte integers in the sorting subroutine:
c     
      call sortem(1,nlooku,tmp,1,order,c,d,e,f,g,h)
      do il=1,nlooku
         loc = int(order(il))
         iz  = int((loc-1)/MAXCXY) + 1
         iy  = int((loc-(iz-1)*MAXCXY-1)/MAXCTX) + 1
         ix  = loc-(iz-1)*MAXCXY - (iy-1)*MAXCTX
         iznode(il) = int(iz)
         iynode(il) = int(iy)
         ixnode(il) = int(ix)
      end do
      if(nodmax.gt.MAXNOD) then
         write(ldbg,*)
         write(ldbg,*) 'The maximum number of close nodes = ',nodmax
         write(ldbg,*) 'this was reset from your specification due '
         write(ldbg,*) 'to storage limitations.'
         nodmax = MAXNOD
      endif
c
c Debugging output if requested:
c
      if(idbg.lt.2) return
      write(ldbg,*)
      write(ldbg,*) 'There are ',nlooku,' nearby nodes that will be '
      write(ldbg,*) 'checked until enough close data are found.'
      write(ldbg,*)
      if(idbg.lt.14) return
      do i=1,nlooku
         xx = (ixnode(i) - nctx - 1) * xsiz
         yy = (iynode(i) - ncty - 1) * ysiz
         zz = (iznode(i) - nctz - 1) * zsiz
         write(ldbg,100) i,xx,yy,zz
      end do
 100  format('Point ',i3,' at ',3f12.4)
c     
c     All finished:
c     
      return
      end
      
