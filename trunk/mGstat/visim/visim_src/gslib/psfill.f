      subroutine psfill(np,x,y,lwidt,gray)
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
c
c CALLING ARGUMENTS:
c
c  x            X location of the center of the box
c  y            Y location of the center of the box
c  np           number of points
c  lwidt        The width of the line (1.0 = dark, 0.5 = light)
c  gray         the grayness of the fill area
c
c NOTES:
c
c  1. The pxmin,pxmax,.. variables are in the standard 1/72 inch 
c     resolution of the postscript page. If a different scale is 
c     going to be used in the printing set pscl to the scale.
c
c
c
c-----------------------------------------------------------------------
      parameter(EPSLON=0.0001)
      real lwidt,x(1),y(1)
c
c Common Block for Postscript Output Unit and Scaling:
c
      common /psdata/ lpsout,pscl,pxmin,pxmax,pymin,pymax,xmin,
     +                xmax,ymin,ymax
c
c Change the line width:
c
      if(pscl.lt.0.01) pscl = 1.0
      width = lwidt/pscl
      write(lpsout,103) width
c
c Start a new path and loop through the points:
c
      write(lpsout,100)
      do i=1,np
            ix = int(resc(xmin,xmax,pxmin,pxmax,x(i))/pscl)
            iy = int(resc(ymin,ymax,pymin,pymax,y(i))/pscl)
            if(i.eq.1) then
                  write(lpsout,101) ix,iy
            else
                  write(lpsout,102) ix,iy
            endif
      end do         
      if(lwidt.le.EPSLON) then
            write(lpsout,104) gray
      else
            write(lpsout,105) gray
      endif
 100  format('n')
 101  format(i5,1x,i5,1x,'m')
 102  format(i5,1x,i5,1x,'l')
 103  format(f6.3,' setlinewidth')
 104  format('c',/,f4.2,' setgray',/,'fill',/,'0.0 setgray')
 105  format('c gsave ',/,f4.2,' setgray',/,'fill',/,'grestore s',
     +         /,'0.00 setgray')
      return
      end
