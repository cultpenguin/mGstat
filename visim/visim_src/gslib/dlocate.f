      subroutine dlocate(xx,n,is,ie,x,j)
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
c Given an array "xx" of length "n", and given a value "x", this routine
c returns a value "j" such that "x" is between xx(j) and xx(j+1).  xx
c must be monotonic, either increasing or decreasing.  j=0 or j=n is
c returned to indicate that x is out of range.
c
c Modified to set the start and end points by "is" and "ie" 
c
c Bisection Concept From "Numerical Recipes", Press et. al. 1986  pp 90.
c-----------------------------------------------------------------------
      implicit real*8 (a-h,o-z)
      dimension xx(n)
c
c Initialize lower and upper methods:
c
      jl = is-1
      ju = ie
c
c If we are not done then compute a midpoint:
c
 10   if(ju-jl.gt.1) then
            jm = (ju+jl)/2
c
c Replace the lower or upper limit with the midpoint:
c
            if((xx(ie).gt.xx(is)).eqv.(x.gt.xx(jm))) then
                  jl = jm
            else
                  ju = jm
            endif
            go to 10
      endif
c
c Return with the array index:
c
      j = jl
      return
      end
