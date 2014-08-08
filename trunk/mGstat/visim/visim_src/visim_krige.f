      subroutine krige(ix,iy,iz,xx,yy,zz,lktype,gmean,cmean,cstdev)
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
c            Builds and Solves the SK or OK Kriging System
c            *********************************************
c
c INPUT VARIABLES:
c
c   ix,iy,iz        index of the point currently being simulated
c   xx,yy,zz        location of the point currently being simulated
c
c
c
c OUTPUT VARIABLES:
c
c   cmean           kriged estimate
c   cstdev          kriged standard deviation
c
c
c
c EXTERNAL REFERENCES: ksol   Gaussian elimination system solution
c
c
c
c ORIGINAL: C.V. Deutsch                               DATE: August 1990
c-----------------------------------------------------------------------
      use geostat_allocate
	  include 'visim.inc'
      logical first
      real	spos(MAXKR1)
      integer ix1,ix2,iy1,iy2,iz1,iz2
      
      if (idbg.gt.14) then
         write(*,*) 'DSSIM KRIGING'
      endif

c
c Size of the kriging system:
c
      first = .false.
      na    = nclose + ncnode
      if(lktype.eq.0) neq = na
      if(lktype.eq.1) neq = na + 1
      if(lktype.eq.2) neq = na
      if(lktype.eq.3) neq = na + 2
      if(lktype.eq.4) neq = na + 1
c
c Set up kriging matrices:
c
		
      in=0
      do j=1,na
c
c Sort out the actual location of point "j"
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
c It is a previously simulated node (keep index for table look-up):
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
c Sort out the actual location of point "i"
c
                  if(i.le.nclose) then
                        index  = int(close(i))
                        x2     = x(index)
                        y2     = y(index)
                        z2     = z(index)
                  else
c
c It is a previously simulated node (keep index for table look-up):
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
c Now, get the covariance value:
c
                  in = in + 1
c
c Decide whether or not to use the covariance look-up table:
c
                  if(j.le.nclose.or.i.le.nclose) then
                        call cova3(x1,y1,z1,x2,y2,z2,1,nst,MAXNST,c0,it,
     +                             cc,aa,1,MAXROT,rotmat,cmax,cov)
                        a(in) = dble(cov)
                  else
c
c Try to use the covariance look-up (if the distance is in range):
c
                        ii = nctx + 1 + (ix1 - ix2)
                        jj = ncty + 1 + (iy1 - iy2)
                        kk = nctz + 1 + (iz1 - iz2)
                        if(ii.lt.1.or.ii.gt.MAXCTX.or.
     +                     jj.lt.1.or.jj.gt.MAXCTY.or.
     +                     kk.lt.1.or.kk.gt.MAXCTZ) then
                              call cova3(x1,y1,z1,x2,y2,z2,1,nst,MAXNST,
     +                             c0,it,cc,aa,1,MAXROT,rotmat,cmax,cov)
                        else
                              cov = covtab(ii,jj,kk)
                        endif
                        a(in) = dble(cov)
                  endif
            end do
c
c Get the RHS value (possibly with covariance look-up table):
c
            if(j.le.nclose) then
                  call cova3(xx,yy,zz,x1,y1,z1,1,nst,MAXNST,c0,it,cc,aa,
     +                       1,MAXROT,rotmat,cmax,cov)
                  r(j) = dble(cov)
            else
c
c Try to use the covariance look-up (if the distance is in range):
c
                  ii = nctx + 1 + (ix - ix1)
                  jj = ncty + 1 + (iy - iy1)
                  kk = nctz + 1 + (iz - iz1)
                  if(ii.lt.1.or.ii.gt.MAXCTX.or.
     +               jj.lt.1.or.jj.gt.MAXCTY.or.
     +               kk.lt.1.or.kk.gt.MAXCTZ) then
                        call cova3(xx,yy,zz,x1,y1,z1,1,nst,MAXNST,c0,it,
     +                             cc,aa,1,MAXROT,rotmat,cmax,cov)
                  else
                        cov = covtab(ii,jj,kk)
                  endif
                  r(j) = dble(cov)
            endif
            rr(j) = r(j)
c            write(*,*) 'DSS r,rr',r(j),rr(j),j
c            if (idbg.gt.13) then
c               write(*,*) 'SK rr(',j,')=',rr(j),r(j) 
c            endif
      end do


c
c Addition of OK constraint:
c
      if(lktype.eq.1.or.lktype.eq.3) then
            do i=1,na
                  in    = in + 1
c gvar???
                  a(in) = 1.0
            end do
            in       = in + 1
            a(in)    = 0.0
            r(na+1)  = 1.0
            rr(na+1) = 1.0
c            write(*,*) 'OK rr(',ii,')=',rr(ii),r(ii) 
      endif

c
c Addition of the External Drift Constraint:
c
      if(lktype.eq.3) then
            edmin =  999999.
            edmax = -999999.
            do i=1,na
                  in    = in + 1
                  a(in) = vrea(i)
                  if(a(in).lt.edmin) edmin = a(in)
                  if(a(in).gt.edmax) edmax = a(in)
            end do
            in       = in + 1
            a(in)    = 0.0
            in       = in + 1
            a(in)    = 0.0
            ind      = ix + (iy-1)*nx + (iz-1)*nxy
            r(na+2)  = dble(lvm(ind))
            rr(na+2) = r(na+2)
            if((edmax-edmin).lt.EPSLON) neq = neq - 1
c            write(*,*) 'EXTD rr(',ii,')=',rr(ii),r(ii) 
      endif
c
c Addition of Collocated Cosimulation Constraint:
c

      if(lktype.eq.4) then
            sfmin =  1.0e21
            sfmax = -1.0e21
            do i=1,na
                  in    = in + 1
                  a(in) = colocorr*r(i)
                  if(a(in).lt.sfmin) sfmin = a(in)
                  if(a(in).gt.sfmax) sfmax = a(in)
            end do
            in    = in + 1
            a(in) = 1.0
            ii    = na + 1
            r(ii) = dble(colocorr)
            rr(ii)= r(ii)
c            write(*,*) 'COL rr(',ii,')=',rr(ii),r(ii) 
c           if((sfmax-sfmin).lt.EPSLON) neq = neq - 1
      end if


c
c Write out the kriging Matrix if Seriously Debugging:
c

c	do i = 1, neq*neq
c		a(i) = a(i)/gvar
c	end do
c	do i = 1, neq
c                r(i) = r(i)/gvar
c        end do


      if(idbg.ge.333) then
            write(ldbg,100) ix,iy,iz
            write(*,100) ix,iy,iz
            is = 1
            do i=1,neq
                  ie = is + i - 1
                  write(ldbg,101) i,r(i),(a(j),j=is,ie)
                  write(*,101) i,r(i),(a(j),j=is,ie)
c                  write(*,101) i,rr(i),(a(j),j=is,ie)
                  is = is + i
            end do
 100        format(/,'Kriging Matrices for Node: ',3i4,' RHS first')
 101        format('    r(',i2,') =',f7.4,'  a= ',99f7.4)
      endif
c


c Solve the Kriging System:
c

      if(neq.eq.1.and.lktype.ne.3) then
            s(1)  = r(1) / a(1)
            ising = 0
      else

            call ksol(1,neq,1,a,r,s,ising)
      endif
c
c Write a warning if the matrix is singular:
c
      if(ising.ne.0) then
            if(idbg.ge.331) then
                  write(ldbg,*) 'WARNING : singular matrix'
                  write(ldbg,*) '          for node',ix,iy,iz
            endif
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
      cmean  = 0.0
      cstdev = cbb
      sumwts = 0.0
      if (idbg.gt.333) then
c         write(*,*) 'CMEAN,SDEV,SUMW:',cmean,cstdev,sumwts
      endif
      do i=1,na
            cmean  = cmean  + real(s(i))*vra(i)
            cstdev = cstdev - real(s(i)*rr(i))
            sumwts = sumwts + real(s(i))
            if (idbg.gt.333) then
c               write(*,*) 'SUM : ',cmean,cstdev,sumwts,rr(i),r(i)
c               write(*,*) 'SUM : ',rr(i),r(i)
            endif
      end do

      if(lktype.eq.0) cmean = cmean +(1.0-sumwts)*gmean
      if (idbg.gt.333) then
c         write(*,*) 'SUM : ',cmean,cstdev,sumwtsj
      endif

      if(lktype.eq.1) cstdev = cstdev - real(s(na+1))

      if(lktype.eq.2) cmean  = cmean + gmean

      if(lktype.eq.4) then
            ind    = ix + (iy-1)*nx + (iz-1)*nxy
            cmean  = cmean  + real(s(na+1))*lvm(ind)
            cstdev = cstdev - real(s(na+1) *rr(na+1))
      end if


c     
c     if cmean negative, and in case the local conditional distribution
c     is lognormal (idrawopt=1), than the weights s(1....na+1) are shifted
c     such that cmean is recalculated to be positive
c     
      
      if (cmean .le. 0.0) then
         
         write(ldbg,*) 'Before changing : cmean, cstdev ',cmean,cstdev
         if (idrawopt .eq. 9999) then
c         if (idrawopt .eq. 1) then
c     REMOVED IN VISIM
            
            wmin = 9999.9
            do i = 1, neq
               if (s(i) .le. wmin) wmin = real(s(i))
            end do
            if (lktype.eq.0) then
               if ((1-sumwts) .le. wmin) wmin = 1-sumwts
            end if
            
            do i = 1, neq
               spos(i) = real(s(i))+abs(wmin)
            end do	
            
            if (lktype.eq.0) then
               wmean = 1-sumwts+abs(wmin)
            end if
            
            
            cmean  = 0.0
            sumwts = 0.0
            
            do i=1,na
               cmean  = cmean  + spos(i)*vra(i)
               sumwts = sumwts + real(s(i))
            end do
            
            if(lktype.eq.0) cmean = cmean + wmean*gmean
            
            if(lktype.eq.2) cmean  = cmean + gmean
            
            if(lktype.eq.4) then
               ind    = ix + (iy-1)*nx + (iz-1)*nxy
               cmean  = cmean  + spos(na+1)*lvm(ind)
            end if
            
            do i = 1, neq
               write(ldbg,*) real(s(i)),spos(i)
            end do
            
c     write(ldbg,*) cmean
            
         end if
      end if
      

c     
c     Error message if negative variance:
c     
      if(cstdev.lt.0.0) then
         write(ldbg,*) 'ERROR: Negative Variance: ',cstdev
         cstdev = 0.0
      endif
      
      cstdev = sqrt(cstdev)
c     
c     Write out the kriging Weights if Seriously Debugging:
c     
      if(idbg.ge.333) then
         do i=1,na
            write(ldbg,140) i,vra(i),s(i)
            write(*,140) i,vra(i),s(i)
         end do
 140     format(' Data ',i4,' value ',f10.4,' weight ',f10.4)
         if(lktype.eq.4) write(ldbg,141) lvm(ind),s(na+1)
         if(lktype.eq.4) write(*,141) lvm(ind),s(na+1)
 141     format(' Sec Data  value ',f10.4,' weight ',f10.4)
         write(ldbg,142) gmean,cmean,cstdev
         write(*,142) gmean,cmean,cstdev
 142     format(' Global mean ',f10.4,' conditional ',f10.4,
     +        ' std dev ',f10.4)
      end if
c     
c     Finished Here:
c
      return
      end
