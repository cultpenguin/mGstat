      subroutine red(value,hexrep,rfrac)
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
c Provided with a real value ``value'' this subroutine returns the red
c portion of the color specification.
c
c Note common block "color" and call to "hexa"
c
c-----------------------------------------------------------------------
      real            value
      character       hexrep*2,hexa*2
      common /color/  cmin,cmax,cint(4),cscl
      hexrep='00'
      if(value.lt.cint(1))then
c
c Scale it between (y0,0):
c
            integ=int((cint(1)-value)/(cint(1)-cmin)*cscl)
            if(integ.gt.255) integ = 255
            if(integ.lt.0)   integ = 0
      else if((value.ge.cint(1)).and.(value.lt.cint(3)))then
c
c Scale it between (0,0):
c
            integ  = 0
      else if((value.ge.cint(3)).and.(value.lt.cint(4)))then
c
c Scale it between (0,255):
c
            integ = int((value-cint(3))/(cint(4)-cint(3))*255.)
            if(integ.gt.255) integ = 255
            if(integ.lt.0)   integ = 0
      else if(value.ge.cint(4))then
c
c Scale it between (255,255):
c
            integ  = 255
      end if
c
c Establish coding and return:
c
      rfrac  = real(integ) / 255.
      hexrep = hexa(integ)
      return
      end
