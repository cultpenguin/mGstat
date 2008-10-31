      real function  simu(cmean1, cstdev1)
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
      
c     
c     This function draws from the local conditional distribution and return
c     the value simu. The drawing depends on the type of local distribution 
c     specified in idrawopt
c     
      
      include  'visim.inc'
      real*8   acorni 
      real p  
      real cmean1, cstdev1
      real aunif, bunif   
      real cvarn, cmn, zt, cvar
      
      
      p = acorni(idum)
      
      if(idrawopt.eq.0) then   
         call gauinv(dble(p),zt,ierr)
         simu=zt*cstdev1+cmean1            
      else if(idrawopt.eq.1) then   
c     USE DSSIM HR CODE
          simu = drawfrom_condtab(cmean1,cstdev1,p)
      else	
         write(*,*) 'Error: drawing option larger than 1'     
         write(*,*) 'No implementation for this option'
      endif
      

      
      if(simu.lt.zmin) then
c      	write(*,*) 'ZMIN VIOLATION',zmin,simu
      endif
      if(simu.gt.zmax) then
c      	write(*,*) 'ZMAX VIOLATION',zmax,simu
      endif
      
      return
      end
      
