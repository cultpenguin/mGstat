      real function powint(xlow,xhigh,ylow,yhigh,xval,pow)
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
c Power interpolate the value of y between (xlow,ylow) and (xhigh,yhigh)
c                 for a value of x and a power pow.
c
c-----------------------------------------------------------------------
      parameter(EPSLON=1.0e-20)

      if((xhigh-xlow).lt.EPSLON) then
            powint = (yhigh+ylow)/2.0
      else
            powint = ylow + (yhigh-ylow)* 
     +               (((xval-xlow)/(xhigh-xlow))**pow)
      end if

      return
      end
