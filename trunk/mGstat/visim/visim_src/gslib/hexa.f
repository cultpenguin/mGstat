      character*2 function hexa(number)
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
c        Return the Hexadecimal Representation of a Number
c        *************************************************
c
c
c
c-----------------------------------------------------------------------
      character*1 hex(16) 
      integer     number,digit1,digit2
      data hex    /'0','1','2','3','4','5','6','7','8',
     +             '9','A','B','C','D','E','F'/

      if(number.gt.255) number = 255
      if(number.lt.1)   number =   1
      
      digit1 = number/16
      digit2 = number-16*digit1

      hexa=hex(digit1+1)//hex(digit2+1)

      return
      end
