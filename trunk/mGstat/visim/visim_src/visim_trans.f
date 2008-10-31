      subroutine pre_trans 
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
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c 
c The subroutine is called to read in the target histogram from another
c file. It is only called once when doing multiple times of realization
c
c INPUT/OUTPUT Parameters
c
c  distin	file with target histogram  
c  ivrr,iwtr   	columns for variable and weight(0=none)
c  tmin,tmax   	trimming limits
c
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      include 'visim.inc'
      real var(50) 
      logical testfl
      
c
c     read in the target histogram
c     
      inquire(file=distin,exist=testfl)
      if(.not.testfl) then
         write(*,*) 'ERROR: No reference distribution file'
         stop
      endif
      open(lin,file=distin,status='UNKNOWN')
      
c     
c     Proceed with reading in distribution:
c     
      read(lin,'(a)',err=198) str
      read(lin,*,err=198)     nvari
      do i=1,nvari
         read(lin,'()',err=198)
      end do
      
c     
c     Read as much data for target histogram as possible:
c     
      
      ncut = 0
      tcdf = 0
 2    read(lin,*,end=3,err=198) (var(j),j=1,nvari)
      
      
      if(var(ivrr).lt.tmin.or.var(ivrr).ge.tmax) go to 2
      
      vrt = var(ivrr) 
      wtt = 1.0
      if(iwtr.ge.1) wtt = var(iwtr)
      
      ncut = ncut + 1
      if(ncut.gt.MAXREF) then
         write(*,*) 'ERROR: exceeded available storage for'
         write(*,*) '       reference, available: ',MAXREF
         stop
      endif
      rvr(ncut)  = vrt
      rcdf(ncut) = wtt
      tcdf = tcdf + wtt

c     
c     Go back for another data?
c
      go to 2
 3    close(lin)
      
            
c     write(ldbg,*) 'ncut=', ncut, 'icut=', icut
c     write(ldbg, *) (rvr(i), i=1, ncut)
c     write(ldbg, *) (rcdf(i), i=1, ncut)
      
      
c        
c     Sort the Reference Distribution and Check for error situation:
c     
      call sortem(1,ncut,rvr,1,rcdf,c,d,e,f,g,h)
      if(ncut.le.1.or.tcdf.le.EPSLON) then
         write(*,*) 'ERROR: too few data or too low weight'
            stop
         endif
         if(utail.eq.4.and.rvr(ncut).le.0.0) then

            write(*,*) 'ERROR can not use hyperbolic tail with '
            write(*,*) '      negative values! - see manual '
            stop
         endif
c     
c     Turn the (possibly weighted) distribution into a cdf that is useful:
c     
      tcdf  = 1.0 / tcdf
      oldcp = 0.0
      cp    = 0.0
      do i=1,ncut
         cp     = cp + rcdf(i) * tcdf
            rcdf(i) =(cp + oldcp) * 0.5
            oldcp  = cp
         end do
         
      IF(IDBG.GE.3) then       
         write(ldbg, *) 'after sortem and calcthe correct rcdf rvr='
         write(ldbg, *) (rvr(i), i=1, ncut)
         write(ldbg, *) 'after sortem and calc the correct rcdf rcdf='
         write(ldbg, *) (rcdf(i), i=1, ncut)
      end if 
      
c
c     Write Some of the Statistics to the screen:
c     
      call locate(rcdf,ncut,1,ncut,0.5,j)
      gmedian = powint(rcdf(j),rcdf(j+1),rvr(j),rvr(j+1),0.5,1.0)
      write(*,900) ncut,gmedian
 900  format(/' There are ',i8,' data in reference dist,',/,
     +     '   median value        = ',f12.5)
      
      IF(IDBG.GE.3) then
         write(ldbg, *) 'ncut=', ncut
         write(ldbg, *) 'in pre_trans rvr='
         write(ldbg, *) (rvr(i), i=1, ncut)
         write(ldbg, *) 'in pre_trans rcdf='
         write(ldbg, *) (rcdf(i), i=1, ncut)
      end if 
      
      return 
      
 198  stop 'ERROR in global data file!'
      
      end 
      





      subroutine trans

c-----------------------------------------------------------------------
c
c                      Univariate Transformation
c                      *************************
c
c Transforms the values in each of the sequential simu;ation 
c such that their histograms match that of the reference distribution.
c
c
c
c INPUT/OUTPUT Parameters:
c
c   sim         dataset with uncorrected distributions
c   tmin,tmax   trimming limits
c   outfl       file for output distributions
c   nsim        size to transform, number of realizations
c   nx, ny, nz  size of categorical variable realizations to transform
c   nxyz        size to of continuous variable data set to transform
c   zmin,zmax   minimum and maximum data values
c   ltail,ltpar lower tail: option, parameter
c   utail,utpar upper tail: option, parameter
c   icond       honor local data (1=yes, 0=no)
c   localfl     file with estimation variance
c   ikv         column number
c   wtfac       control parameter
c
c
c
c The following Parameters control static dimensioning:
c
c   MAXREF    maximum number of data for reference distribution
c   MAXDAT    maximum number of data to transform (e.g., max. nx*ny*nz)
c   MAXCAT    maximum number of categories
c
c
c
c-----------------------------------------------------------------------

      include 'visim.inc'
 
      character str*40
      real var(20)
      logical   testfl

	print *,'Transforming data '
      
      if(idbg.ge.3) then
         write(*,*) 'The simulation resuls from visim is shown below'
         write(ldbg, *) (sim(i), i=1, nxyz)  
      end if 
      
    
      if(idbg.ge.3) then      	
         write(ldbg,*) 'isim=', isim, 'nsim=' , nsim
      end if 
      
      ivrd=1
      iwtd=0
ccccccccccccccccccccccccccccccccc
      
      
      
c     
c     transfer the data values from visim simulation sim() to dvr():
c     keep this block unchanged 
c     
         
            tcdf = 0.0
            num  = 0
            do i=1,nxyz     
               num = num + 1 
               dvr(num)  = sim(i) 
               indx(num) = real(num)
               wtd = 1.0
               dcdf(num) = wtd
               tcdf      = tcdf + wtd
            end do  
            
            if(tcdf.le.EPSLON) then
               write(*,*) 'ERROR: no data'
               stop
            endif
            
            

c     
c     Turn the (possibly weighted) data distribution into a useful cdf:
c     
            
            call sortem(1,num,dvr,2,dcdf,indx,d,e,f,g,h)

        
            oldcp = 0.0
            cp    = 0.0
            tcdf  = 1.0 / tcdf
            
            do i=1,num
               cp     = cp + dcdf(i)*tcdf     
               dcdf(i) =(cp + oldcp) /2.
               if(dcdf(i).ge.1) dcdf(i) = 0.99
               
c     
c     The above algorithm theoretically garantee that dcdf should not be 
c     larger than 1 
c     However it happens only when n is very large, so that 
c     the machine numerical acuracy is not enough to get the correct dcdf value. 
c     
               oldcp  = cp
            end do
            
            
            
c     
c     Now, get the right order back:
c
            call sortem(1,num,indx,2,dcdf,dvr,d,e,f,g,h)
 
            

c   	    WRITE(ldbg,*) 'OK after sortem dcdf'

c
c Get the kriging variance to array "indx" if we have to honor
c local data: The kriging variance matrix is either read in or 
c calculated
c 
            if(icond.eq.1) then
	       if(ivar.eq.1) then 	
                  open(lkv,file=localfl,err=195,status='OLD')
                  read(lkv,'()',err=195)
                  read(lkv,*,   err=195) nvarik
                  do i=1,nvarik
                     read(lkv,'()',err=195)
                  end do
                  evmax = -1.0e21
                  do i=1,num
                     read(lkv,*,err=195) (var(j),j=1,nvarik)
                     indx(i) = var(icoll)
                     indx(i) = sqrt(max(indx(i),0.0)) 
                     if(indx(i).gt.evmax) evmax = indx(i)
                  end do
                  close(lkv)
	       else 
                  evmax = -1.0e21
                  do i=1,num
                     indx(i) = krgvar(i)
                     indx(i) = sqrt(max(indx(i),0.0))
                     if(indx(i).gt.evmax) evmax = indx(i)
                  end do
               end if                  
            end if
            
c     WRITE(ldbg,*) 'after icond.eq.1, whether to honor local data'
            

c     
c     Go through all the data back transforming them to the reference CDF:
c     
            
            ne = 0  
            av = 0.0
            ss = 0.0
            


            do i=1,num 

c		print *,'start getz'
c		print *,dcdf(i),num
               zval = getz(dcdf(i),ncut,rvr,rcdf,zmin,
     +              zmax,ltail,ltpar,utail,utpar)
c      		print *,'finished getz'
               
c     
c Now, do we have to honor local data?
c     
               if(icond.eq.1) then
                  
                  if(indx(i).eq.0) then 
                     wtw = 0.
                  else
                     wtw = (indx(i)/evmax)**wtfac
                  end if
                  zval = dvr(i)+wtw*(zval-dvr(i))
               end if
               
               ne = ne + 1   
               av = av + zval
               ss = ss + zval*zval
               write(ldbg, *) 'The transformed value is :'
               write(ldbg, *) zval
               call numtext(zval,str(1:12))
               write(lout,'(a12)') str(1:12)
            end do
            
c     
c     calculate some statistics
c     
 
	    av = av / max(real(ne),1.0)
            ss =(ss / max(real(ne),1.0)) - av * av
            if (idbg.gt.-2) then
              print *,'Finished trans'           
              write(ldbg,112) isim,ne,av,ss
              write(*,   112) isim,ne,av,ss
 112          format(/,' Realization ',i3,': number   = ',i8,/,
     +           '                  mean     = ',f12.4,
     +           ' (close to target mean)',/,
     +           '                  variance = ',f12.4,
     +           ' (close to target variance)',/)
              endif
            
c     
c     Finished:
c     
            
c     write(*,9998) VERSION
c     9998 format(/' TRANS Version: ',f5.3, ' Finished'/)
            

            return

            

 195        stop 'ERROR in kriging variance file!'
            


            end
