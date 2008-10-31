      subroutine blue(value,hexrep,bfrac)
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
c Provided with a real value ``value'' this subroutine returns the blue
c portion of the color specification.
c
c Note common block "color" and call to "hexa"
c
c-----------------------------------------------------------------------
      real            value
      character       hexrep*2,hexa*2
      common /color/  cmin,cmax,cint(4),cscl
      hexrep = '00'
      if(value.lt.cint(2))then
c
c Scale it between (255,255):
c
            integ  = 255
      else if((value.ge.cint(2)).and.(value.lt.cint(3)))then
c
c Scale it between (255,0):
c
            integ = int((cint(3)-value)/(cint(3)-cint(2))*255.)
            if(integ.gt.255) integ = 255
            if(integ.lt.0)   integ = 0
      else if(value.ge.cint(3))then
c
c Scale it between (0,0):
c
            integ  = 0
      end if
c
c Establish coding and return:
c
      bfrac  = real(integ) / 255.
      hexrep = hexa(integ)
      return
      end
