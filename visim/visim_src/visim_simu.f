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
c
c     ADAPTION : Thomas Mejer Hansen                DATE: August 2005-2015
c

      include  'visim.inc'
      real*8   acorni
      real p
      real cmean1, cstdev1
      real aunif, bunif
      real cvarn, cmn, zt, cvar

c   get random number
      p = acorni(idum)

      if(idrawopt.eq.0) then
c   Traditional Gaussian simualation
         call gauinv(dble(p),zt,ierr)
         simu=zt*cstdev1+cmean1
      else if(idrawopt.eq.1) then
c   Simulation mathching a 1D marginal distribution
        simu = drawfrom_condtab(cmean1,cstdev1,p)

        if(simu.lt.zmin) then
            if (idbg.gt.1) then
                write(*,*) 'VISIM_SIMU: ZMIN VIOLATION',zmin,simu
            endif
            simu=zmin
        endif
        if(simu.gt.zmax) then
            if (idbg.gt.1) then
                write(*,*) 'VISIM_SIMU: ZMAX VIOLATION',zmax,simu
            endif
            simu=zmax
        endif

      else
         write(*,*) 'Error: drawing option larger than 1'
         write(*,*) 'No implementation for this option'
      endif


      return
      end

