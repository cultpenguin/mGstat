      real function backtr(vrgs,nt,vr,vrg,zmin,zmax,ltail,ltpar,
     +                     utail,utpar,discrete)
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
c           Back Transform Univariate Data from Normal Scores
c           *************************************************
c
c This subroutine backtransforms a standard normal deviate from a
c specified back transform table and option for the tails of the
c distribution.  Call once with "first" set to true then set to false
c unless one of the options for the tail changes.
c
c
c
c INPUT VARIABLES:
c
c   vrgs             normal score value to be back transformed
c   nt               number of values in the back transform tbale
c   vr(nt)           original data values that were transformed
c   vrg(nt)          the corresponding transformed values
c   zmin,zmax        limits possibly used for linear or power model
c   ltail            option to handle values less than vrg(1):
c   ltpar            parameter required for option ltail
c   utail            option to handle values greater than vrg(nt):
c   utpar            parameter required for option utail
c
c
c   MODIFIED by TMH 10/2008, to allow discrete target distribution
c
c-----------------------------------------------------------------------
      parameter(EPSLON=1.0e-20)
      dimension vr(nt),vrg(nt)
      real      ltpar,utpar,lambda
      integer   ltail,utail
      real vrgs
      integer discrete

c      write(*,*) 'ARG 1 = ',vrgs,vrg(1),vrg(2)
c      write(*,*) 'discrete ? ',discrete

c
c Value in the lower tail?    1=linear, 2=power, (3 and 4 are invalid):
c
c      if(vrgs.le.vrg(1)) then
      if(vrgs.lt.vrg(1)) then
c         write(*,*) 'lower tail', vrgs, vrg(1)
            backtr = vr(1)
            cdflo  = gcum(vrg(1))
            cdfbt  = gcum(vrgs)
            if(ltail.eq.1) then
                  backtr = powint(0.0,cdflo,zmin,vr(1),cdfbt,1.0)
            else if(ltail.eq.2) then
                  cpow   = 1.0 / ltpar
                  backtr = powint(0.0,cdflo,zmin,vr(1),cdfbt,cpow)
            endif
c
c Value in the upper tail?     1=linear, 2=power, 4=hyperbolic:
c
c      else if(vrgs.ge.vrg(nt)) then
      else if(vrgs.gt.vrg(nt)) then
c         write(*,*) 'upper tail'
            backtr = vr(nt)
            cdfhi  = gcum(vrg(nt))
            cdfbt  = gcum(vrgs)
            if(utail.eq.1) then
                  backtr = powint(cdfhi,1.0,vr(nt),zmax,cdfbt,1.0)
            else if(utail.eq.2) then
                  cpow   = 1.0 / utpar
                  backtr = powint(cdfhi,1.0,vr(nt),zmax,cdfbt,cpow)
            else if(utail.eq.4) then
                  lambda = (vr(nt)**utpar)*(1.0-gcum(vrg(nt)))
                  backtr = (lambda/(1.0-gcum(vrgs)))**(1.0/utpar)
            endif
      else
cc Value within the transformation table:
c
c         write(*,*) 'IN table',discrete
c         stop

            call locate(vrg,nt,1,nt,vrgs,j)
            j = max(min((nt-1),j),1)
c            backtr = powint(vrg(j),vrg(j+1),vr(j),vr(j+1),vrgs,1.0)
	     if (discrete.eq.1) then

		     if ((vrgs-vrg(j)).lt.(vrg(j+1)-vrgs)) then
			backtr = vr(j)
		     else
			backtr = vr(j+1);
		     endif
c		     write(*,*) '1',backtr
c	             backtr = nearint(vrg(j),vrg(j+1),vr(j),vr(j+1),vrgs)
c	             write(*,*) '2',backtr
	    
	     else
                 backtr = powint(vrg(j),vrg(j+1),vr(j),vr(j+1),vrgs,1.0)
	     endif
c 	write(*,*) 'backtr=',backtr
c	stop	
      endif
      
      
      return
      end
