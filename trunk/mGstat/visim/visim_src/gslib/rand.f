      subroutine rand(seed,n,vector)
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
c---------------------------------------------------------------------
c
c This random number generator generates random numbers in ]0,1[
c Note that if the seed value is zero on the first call, a default
c value of 7931 will be used  in a linear congruential generator to
c generate 55 odd integers for the array 'itab()'. These values are
c preserved by a common statement, so that they may be used in sub-
c sequent calls by setting the seed to zero.If the value of 'seed'
c is greater than zero in a call to the subroutine, then the array
c 'itab' will be initialized and a new seed value will be returned
c by the subroutine. Best results are obtained by making the initial
c call with a seed of your choice and then setting the seed to '0'
c for all subsequent calls.
c
c---------------------------------------------------------------------
      dimension vector(*)
      common /unusual/itab(55),n1,n2,nseed
      integer rn1,seed
c
c Test to see if 55 odd integers must be generated.
c
      if((seed.gt.0).or.(nseed.lt.1)) then
            nseed = seed
            if(seed.le.0) nseed  = 7931
            do i=1,55
                  rn1=mod(nseed*9069,32768)
                  if(mod(rn1,2).eq.0) rn1 = rn1-1
                  itab(i) = rn1
                  nseed = rn1
            end do
            n1 = 0
            n2 = 24
      endif
c
c Generate "n" random components for the vector "VECTOR"
c
      do i=1,n
            itab(55-n1) = mod(itab(55-n2)*itab(55-n1),32768)
            vector(i)   = abs(float(itab(55-n1))/float(32768))
            n1 = mod(n1+1,55)
            n2 = mod(n2+1,55)
      end do
      if(seed.gt.0) seed=nseed
c
c Return with the vector of random numbers:
c
      return
      end
