      subroutine makepar
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
c     Write a Parameter File
c     **********************
c     
c
c
c-----------------------------------------------------------------------
      lun = 99
      open(lun,file='visim.par',status='UNKNOWN')
      write(lun,10)
 10   format('                  Parameters for VISIM',/,
     +       '                  ********************',/,/,
     +       'START OF PARAMETERS:')

      write(lun,11)
 11   format('0                             ',
     +       '- conditional simulation (0=no,1=p+v,2=p,3=v)')
      write(lun,12)
 12   format('visim_cond.eas                ',
     +       '- file with conditioning data')
      write(lun,13)
 13   format('1 2 3 4                       ',
     +       '- columns for X,Y,Z,val')
      write(lun,135)
 135  format('visim_volgeom.deas            ',
     +       '- Geometry of volume [x,y,z,l,ivol]')
      write(lun,136)
 136  format('visim_volsum.eas              ',
     +       '- Summary of volgeom.eas. [ivol,nobs,volobs,volvar]')
      write(lun,14)
 14   format('-1.0       1.0e21             ',
     +       '- trimming limits for conditioning data')
      write(lun,15)
 15   format('0 -1 -1 -1 -1 0 0                        ',
     +       '-debugging level: -1,0,1,2,3, read_covtable,',
     +       'read_lambda,read_volnh,read_randpath,do_cholesky,',
     +       'do_error_sim-1,0,1')
      write(lun,17)
 17   format('visim.out                     ',
     +       '-file for output')
      write(lun,18)
 18   format('1                             ',
     +       '-number of realizations to generate')
      write(lun,185)
 185  format('0                             ',
     +       '-ccdf. type: 0-Gaussian, 1: DSSIM histogram')
      write(lun,186)
 186  format('reference.eas                 ',
     +       '- reference histogram')
      write(lun,187)
 187  format('1    0                        ',
     +       '- columes for variable and weights')


      write(lun,119)
119   format('-3.5 3.5 100                  ',
     +       '-min_Gmean,max_Gmean,n_Gmean')
      write(lun,120)
 120  format('0 2 100                       ',
     +       '-min_Gvar,max_Gvar,n_Gvar')
      write(lun,121)
 121  format('170 0                           ',
     +       '-nQ (number of wquantiles, do_discrete')


      write(lun,19)
 19   format('40    0.5    1.0              ',
     +       '-nx,xmn,xsiz')
      write(lun,20)
 20   format('40    0.5    1.0              ',
     +       '-ny,ymn,ysiz')
      write(lun,21)
 21   format('1     0.5    1.0              ',  
     +       '-nz,zmn,zsiz')
      write(lun,22)
 22   format('69069                         ', 
     +       '-random number seed')
      write(lun,23)
 23   format('0     8                       ', 
     +       '-min and max original data for sim')
      write(lun,24)
 24   format('12                            ',
     +       '-number of simulated nodes to use')

      write(lun,224)
 224  format('3 32 0.001                    ',
     +     '-Volume Neighborhood,',
     +     'method[0,1,2] , nusevols, accept_frac')
      
      write(lun,324)
 324  format('3                             ',
     +     '-Random Path, ',
     +     '[1] independent, [2] rays first, [3] preferential')
      
      write(lun,25)
 25   format('1                             ',
     +     '-assign data to nodes (0=no, 1=yes)')
      write(lun,27)
 27   format('0                             ',
     +       '-maximum data per octant (0=not used)')
      write(lun,28)
 28   format('60.0  60.0  60.0              ',
     +       '-maximum search radii (hmax,hmin,vert)')
      write(lun,29)
 29   format(' 0.0   0.0   0.0             ',
     +       '-angles for search ellipsoid')
      write(lun, 305)
 305  format('10.0 2.0                      ',
     +       '- global mean and variance')
      write(lun, 33)
 33   format('1    0.01                     ',   
     +       '-nst, nugget effect')
      write(lun,34)
 34   format('1    2.01  45.0   0.0   0.0   ',
     +       '-it,cc,ang1,ang2,ang3')
      write(lun,35)
 35   format('         50.0  10.0  10.0     ',
     +       '-a_hmax, a_hmin, a_vert')
      write(lun,40)
 40   format('0   100.                      ',
     +       '- zmin,zmax (tail extrapolation for trans)')
      write(lun,41)
 41   format('1       0.0                   ',
     +       '-  lower tail option, parameter')
      write(lun,42)
 42   format('1      3.0                    ',
     +       '-  upper tail option, parameter')
      close(lun)
      return
      end


