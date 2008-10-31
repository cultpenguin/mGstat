      subroutine gauinv(p,xp,ierr)
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
c Computes the inverse of the standard normal cumulative distribution
c function with a numerical approximation from : Statistical Computing,
c by W.J. Kennedy, Jr. and James E. Gentle, 1980, p. 95.
c
c
c
c INPUT/OUTPUT:
c
c   p    = double precision cumulative probability value: dble(psingle)
c   xp   = G^-1 (p) in single precision
c   ierr = 1 - then error situation (p out of range), 0 - OK
c
c
c-----------------------------------------------------------------------
      real*8 p0,p1,p2,p3,p4,q0,q1,q2,q3,q4,y,pp,lim,p
      save   p0,p1,p2,p3,p4,q0,q1,q2,q3,q4,lim
c
c Coefficients of approximation:
c
      data lim/1.0e-10/
      data p0/-0.322232431088/,p1/-1.0/,p2/-0.342242088547/,
     +     p3/-0.0204231210245/,p4/-0.0000453642210148/
      data q0/0.0993484626060/,q1/0.588581570495/,q2/0.531103462366/,
     +     q3/0.103537752850/,q4/0.0038560700634/
c
c Check for an error situation:
c
      ierr = 1
      if(p.lt.lim) then
            xp = -1.0e10
            return
      end if
      if(p.gt.(1.0-lim)) then
            xp =  1.0e10
            return
      end if
      ierr = 0      
c
c Get k for an error situation:
c
      pp   = p
      if(p.gt.0.5) pp = 1 - pp
      xp   = 0.0
      if(p.eq.0.5) return
c
c Approximate the function:
c
      y  = dsqrt(dlog(1.0/(pp*pp)))
      xp = real( y + ((((y*p4+p3)*y+p2)*y+p1)*y+p0) /
     +               ((((y*q4+q3)*y+q2)*y+q1)*y+q0) )
      if(real(p).eq.real(pp)) xp = -xp
c
c Return with G^-1(p):
c
      return
      end
