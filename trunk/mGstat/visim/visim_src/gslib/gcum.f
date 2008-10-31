      real function gcum(x)
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
c Evaluate the standard normal cdf given a normal deviate x.  gcum is
c the area under a unit normal curve to the left of x.  The results are
c accurate only to about 5 decimal places.
c
c
c-----------------------------------------------------------------------
      z = x
      if(z.lt.0.) z = -z
      t    = 1./(1.+ 0.2316419*z)
      gcum = t*(0.31938153   + t*(-0.356563782 + t*(1.781477937 +
     +       t*(-1.821255978 + t*1.330274429))))
      e2   = 0.
c
c  6 standard deviations out gets treated as infinity:
c
      if(z.le.6.) e2 = exp(-z*z/2.)*0.3989422803
      gcum = 1.0- e2 * gcum
      if(x.ge.0.) return
      gcum = 1.0 - gcum
      return
      end
