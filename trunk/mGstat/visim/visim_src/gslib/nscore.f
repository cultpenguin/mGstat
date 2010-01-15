      subroutine nscore(nd,vr,tmin,tmax,iwt,wt,tmp,lout,vrg,ierror,disc)
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
c              Transform Univariate Data to Normal Scores
c              ******************************************
c
c This subroutibe takes "nd" data "vr(i),i=1,...,nd" possibly weighted
c by "wt(i),i=,...,nd" and returns the normal scores transform N(0,1)
c as "vrg(i),i=1,...,nd".  The extra storage array "tmp" is required
c so that the data can be returned in the same order (just in case
c there are associated arrays like the coordinate location).
c
c
c
c INPUT VARIABLES:
c
c   nd               Number of data (no missing values)
c   vr(nd)           Data values to be transformed
c   tmin,tmax        data trimming limits
c   iwt              =0, equal weighted; =1, then apply weight
c   wt(nd)           Weight for each data (don't have to sum to 1.0)
c   tmp(nd)          Temporary storage space for sorting
c   lout             if > 0 then transformation table will be written
c   disc             =0, wt(i) = dble(i)/nd - 1./(2*nd)
c                    =1, wt(i) = dble(i)/nd
c
c
c
c
c OUTPUT VARIABLES:
c
c   vrg(nd)          normal scores
c   ierror           error flag (0=error free,1=problem)
c
c
c
c EXTERNAL REFERENCES:
c
c   gauinv           Calculates the inverse of a Gaussian cdf
c   sortem           sorts a number of arrays according to a key array
c
c
c
c MODIFICATIONS 
c   JAN 2010, TMH : added disc option in order to reproduce 
c                   discrete distributions mor accurately
c
c
c
c-----------------------------------------------------------------------
      parameter(EPSLON=1.0e-20)
      real      vr(nd),wt(nd),vrg(nd),tmp(nd),wt2(nd)
      real*8    pd
      integer   disc
c
c Sort the data in ascending order and calculate total weight:
c
      ierror = 0
      twt    = 0.0
      do i=1,nd
            tmp(i) = real(i)
            if(vr(i).ge.tmin.and.vr(i).lt.tmax) then
                  if(iwt.eq.0) then
                        twt = twt + 1.
                  else
                        twt = twt + wt(i)
                  end if
            end if
      end do
      if(nd.lt.1.or.twt.lt.EPSLON) then
            ierror = 1
            return
      end if
      call sortem(1,nd,vr,2,wt,tmp,d,e,f,g,h)
c
c Compute the cumulative probabilities:
c
      oldcp = 0.0
      cp    = 0.0
      do i=1,nd
c ORIGINAL GSLIB IMPLEMENTATION WAS NOT PRECISE ENOUGH         
c            cp     =  cp + wt(i) / twt
c            wt(i)  = (cp + oldcp)/ 2.0
c            oldcp  =  cp
c USING MORE PRCISE APPROACH :
         if (disc.eq.0) then
            wt(i) = dble(i)/nd - 1./(2*nd)
         else
            wt(i) = dble(i)/nd
         endif
         

         
         
         call gauinv(dble(wt(i)),vrg(i),ierr)
c      write(*,*) i,cp,wt(i),wt2(i),twt,vr(i),vrg(i),nd
         if(lout.gt.0) write(lout,'(f12.5,1x,f12.5,1x,f12.5)') 
     1        wt(i),vr(i),vrg(i)
      end do

c
c Get the arrays back in original order:
c
      call sortem(1,nd,tmp,3,wt,vr,vrg,e,f,g,h)
c
c Finished:
c
      return
      end
