      subroutine readparm
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
c                  Initialization and Read Parameters
c                  **********************************
c
c The input parameters and data are read in from their files. Some quick
c error checking is performed and the statistics of all the variables
c being considered are written to standard output.
c
c
c
c-----------------------------------------------------------------------
      include  'visim.inc'
      real      var(50)
      real*8    p,acorni,cp,oldcp,w
      character cdfl*80,tmpfl*80,datafl*40,btfl*40,
     +          dbgfl*40,lvmfl*40,str*40,parfile*40
      character volgeomfl*40,volsumfl*40,datacovfl*40
      character maskfl*40
      logical   testfl
      integer   ix1,iy1,iz1
      integer   ndinv,ivol,iv,ivol_new,nvoldata,IntVar
      real      ivolx,ivoly,ivolz,ivoll,cumsum,vvtmp,realtmp
      logical   testind 
      integer   tempa,tempb,iargc,tempint
c
c Note VERSION number:
c
c
c Get the name of the parameter file - try the default name if no input:
c
c TMH/05 : USING iargc and getarg to read filename from commandline
c if this cause trouble, uncomment the next 8 lines, and remove 
c comments form the following two lines.
c

      argc = IARGC()

c     call getarg(1,str)
c     if (idbg.gt.-1) write(*,*) 'filename is ', str,argc 

      if ( argc.eq.1 ) then
         call getarg(1,str)
      else
         if (idbg.gt.-10) write(*,*) 'Which parameter file do you 
     1        want to use?'
         read (*,'(a40)') str
      endif
c      if (idbg.gt.-1) write(*,*) 'Which parameter file do you want to use?'
c      read (*,'(a40)') str

      if(str(1:1).eq.' ')str='visim.par                               '
      
      inquire(file=str,exist=testfl)
      if(.not.testfl) then
         if (idbg.gt.-2) write(*,*) 'ERROR - the parameter file does 
     1        not exist,'
         if (idbg.gt.-2) write(*,*) '        check for the file and 
     1        try again  '
         if (idbg.gt.-2) write(*,*)
         if(str(1:20).eq.'visim.par           ') then
            if (idbg.gt.-2) write(*,*) '        creating a blank 
     1           parameter file'
            call makepar
            if (idbg.gt.-2) write(*,*)
         end if
         stop
      endif
      open(lin,file=str,status='OLD')
      parfile=str
c      write(*,*) parfile

c
c Find Start of Parameters:
c
 1    read(lin,'(a4)',end=98) str(1:4)
      if(str(1:4).ne.'STAR') go to 1
c
c Read Input Parameters:
c

      read(lin,*,err=98) icond

      read(lin,'(a40)',err=98) datafl
      call chknam(datafl,40)

      read(lin,*,err=98) ixl,iyl,izl,ivrl
c     NEXT LINE LEFT TO ENABLE EASY UPGRADE TO COKRIGING
      iwt=0
      isecvr=0

      read(lin,'(a40)',err=98) volgeomfl
      call chknam(volgeomfl,40)

      read(lin,'(a40)',err=98) volsumfl
      call chknam(volsumfl,40)


c      datacovfl='visim_datacov.eas'
c      call chknam(datacovfl,40)

      read(lin,*,err=98) tmin,tmax

      read(lin,*,err=98) idbg,read_covtable,read_lambda,
     1 	read_volnh,read_randpath


      
      if (idbg.gt.-2) then
        write(*,*) 'VISIM ',VERSION,' ',parfile
c         write(*,9999) VERSION,parilfe
c 9999    format(' VISIM Version: ',f5.3,' Start',I10)
      endif
c      if (idbg.gt.-2) write(*,*) 'VISIM parfile: ', parfile 


      if (idbg.gt.0) then 
         write(*,*) ' data file = ',datafl
         write(*,*) ' conditional simulation = ', icond
         write(*,*) ' input columns = ',ixl,iyl,izl,ivrl,
     1       iwt,isecvr
         write(*,*) ' data file = ',volgeomfl
         write(*,*) ' data file = ',volsumfl
         write(*,*) ' trimming limits = ',tmin,tmax
         write(*,*) ' debugging level = ',idbg
         
         if (read_covtable.eq.1) then
            write(*,*) ' read covariance lookup tables = YES ['
     1           ,'1]'
         else
            write(*,*) ' read covariance lookup tables = NO ['
     1           ,'0]'
         endif
         
         if (read_lambda.eq.1) then
            write(*,*) ' read lambda from file = YES ['
     1           ,'1] --> NO MATRIX IS INVERTED'
         else
            write(*,*) ' read lambda from file = NO ['
     1           ,'0] --> Traditional kriging'
         endif

      endif

c      read(lin,'(a40)',err=98) dbgfl
c      call chknam(dbgfl,40)
c      if (idbg.gt.-1) write(*,*) ' debugging file = ',dbgfl
c      open(ldbg,file=dbgfl,status='UNKNOWN')

      read(lin,'(a40)',err=98) outfl
      call chknam(outfl,40)
      if (idbg.gt.0) write(*,*) ' output file ',outfl
c      write(*,*) parfile,'.OUT'

c      stop
      tmpfl='debug'//'_'//outfl 
      if (idbg.gt.0) write(*,*) ' debugging file = ',tmpfl
      open(ldbg,file=tmpfl,status='UNKNOWN')

      read(lin,*,err=98) nsim
c     changed for visim
      if (nsim.eq.0) then
         nsim=1
         doestimation=1
         if (idbg.gt.0) write(*,*) ' Doing ESTIMATION rather than 
     1        SIMULATION'
         if (idbg.gt.0) write(*,*) ' since nsim=',nsim,doestimation
      else
         doestimation=0
         if (idbg.gt.0) write(*,*) ' number of realizations = ',nsim
      endif
        


      read(lin,*,err=98) idrawopt
      if (idbg.gt.0) write(*,*) ' Conditional distribution type = ', 
     1     idrawopt

      read(lin,'(a40)',err=98) btfl
c      if ((idrawopt .eq. 2).or.(idrawopt.eq.4)) then
      if (idrawopt.eq.1) then
        call chknam(btfl,40)
      	if (idbg.gt.0) write(*,*) ' Target Histogram file = ',btfl
      end if

      read(lin,*,err=98) ibt,ibtw
      if (idbg.gt.0) write(*,*) ' input columns for histogram file = 
     1     ',ibt,ibtw

c     READ OPTIONS FOR DSSIM HISTOGRAM REPRO, CPDF LOOKUP
      read(lin,*,err=98) min_Gmean, max_Gmean, n_Gmean
      if (idbg.gt.0) write(*,*) ' Nscore MEAN range = ',
     1     min_Gmean, max_Gmean, n_Gmean
      read(lin,*,err=98) min_Gvar, max_Gvar, n_Gvar
      if (idbg.gt.0) write(*,*) ' Nscore VAR range = ',
     1     min_Gvar, max_Gvar, n_Gvar
      read(lin,*,err=98) n_q, discrete
      
      
c     use of n_monte depreceated
      nmonte=1000
      if (idbg.gt.0) write(*,*) ' Number of quantiles = ',n_q
c     if (idbg.gt.0) write(*,*) ' Number of samples drawn 
c     1     in nscore space = ',n_monte
      if (idbg.gt.0) write(*,*) ' Discrete target histogram = ',discrete     
      
      read(lin,*,err=98) nx,xmn,xsiz
      if (idbg.gt.0) write(*,*) ' X grid specification = ',nx,xmn,xsiz

      read(lin,*,err=98) ny,ymn,ysiz
      if (idbg.gt.0) write(*,*) ' Y grid specification = ',ny,ymn,ysiz

      read(lin,*,err=98) nz,zmn,zsiz
      if (idbg.gt.0) write(*,*) ' Z grid specification = ',nz,zmn,zsiz

      nxy  = nx*ny
      nxyz = nx*ny*nz

      read(lin,*,err=98) ixv(1)
      if (idbg.gt.0) write(*,*) ' random number seed = ',ixv(1)
      ixv2(1)=ixv(1)
      p = real(acorni(idum))
      do i=1,1000
         p = real(acorni(idum))
      end do


      if(idbg.ge.2) then
         write(ldbg,*) 'The random seed value p=', p
      end if 

      read(lin,*,err=98) ndmin,ndmax
      if (idbg.gt.0) write(*,*) ' min and max data = ',ndmin,ndmax

      read(lin,*,err=98) nodmax
      if (idbg.gt.0) write(*,*) ' maximum previous nodes = ',nodmax

      read(lin,*,err=98) musevols,nusevols,accept_fract
      if (idbg.gt.0) write(*,*) ' volume neighborhood = ',musevols,
     1     nusevols
      if (doestimation.eq.1) then
c         musevols=0
      endif

c      read(lin,*,err=98) densitypr,shuffvol,shuffinvol
c      if (idbg.gt.0) write(*,*) ' random path = ',
c     1     densitypr,shuffvol,shuffinvol

      read(lin,*,err=98) densitypr
      if (idbg.gt.0) write(*,*) ' random path = ',densitypr

      read(lin,*,err=98) sstrat
      if (idbg.gt.0) write(*,*) ' two-part search flag = ',sstrat
c     CHECK NEXT LINE !!!
c      if(sstrat.eq.1) ndmax = 0

c
c     Multiple grid search is disabled by default in visim
c     but the variables are kept to ease future implementation
c     of MG
c      read(lin,*,err=98) mults,nmult
c      if (idbg.gt.0) write(*,*) ' multiple grid search flag = ',mults,nmult
      mults=0
      nmult=1

      read(lin,*,err=98) noct
      if (idbg.gt.0) write(*,*) ' number of octants = ',noct

      read(lin,*,err=98) radius,radius1,radius2
      if (idbg.gt.0) write(*,*) ' search radii = ',
     1     radius,radius1,radius2
      if(radius.lt.EPSLON) stop 'radius must be greater than zero'
      radsqd = radius  * radius
      sanis1 = radius1 / radius
      sanis2 = radius2 / radius

      read(lin,*,err=98) sang1,sang2,sang3
      if (idbg.gt.0) write(*,*) ' search anisotropy angles = ',
     1     sang1,sang2,sang3

c      read(lin,*,err=98) ktype 
c      if (idbg.gt.0) write(*,*) ' kriging type = ',ktype
c     THE KRIGING TYPE IS SET TO SK for NOW, THOMAS/2005
c     MAYBE THE OTHER TYPES SHOULD BE ENABLED AGAIN.
      ktype=0
      
      colocorr = 1.0
      if(ktype.eq.4) then
            backspace lin
            read(lin,*,err=98) ktype,colocorr
            varred = 1.0
            backspace lin
            read(lin,*,err=9990) i,xx,varred
 9990       continue
            if (idbg.gt.-1) write(*,*) ' correlation coefficient = ',
     1           colocorr
            if (idbg.gt.-1) write(*,*) ' secondary variable varred = ',
     1           varred
      end if
	
      read(lin,*,err=98) skgmean, gvar 
      if (idbg.gt.0) write(*,*) ' kriging type = ',ktype

c     SECONDARY DATA DISABLED
c      read(lin,'(a40)',err=98) lvmfl
c      call chknam(lvmfl,40)
c      if (idbg.gt.0) write(*,*) ' secondary model file = ',lvmfl
c
c      read(lin,*,err=98) icollvm
c      if (idbg.gt.0) write(*,*) ' column in secondary model file = ',icollvm
      lvmfl=''
      icollvm=0

      read(lin,*,err=98) nst(1),c0(1)
      sill = c0(1)
      if (idbg.gt.0) write(*,*) ' nst, c0 = ',nst(1),c0(1)

      if(nst(1).le.0) then
            write(*,9997) nst(1)
 9997       format(' nst must be at least 1, it has been set to ',i4,/,
     +             ' The c or a values can be set to zero')
            stop
      endif



      do i=1,nst(1)

         
         read(lin,*,err=98) it(i),cc(i),ang1(i),ang2(i),ang3(i)
         
            read(lin,*,err=98) aa(i),aa1,aa2
            anis1(i) = aa1 / max(aa(i),EPSLON)
            anis2(i) = aa2 / max(aa(i),EPSLON)
            sill     = sill + cc(i)
            if(it(i).eq.4) then
                  if (idbg.gt.-1) write(*,*) 
     1              ' A power model is NOT allowed '
                  if (idbg.gt.-1) write(*,*) 
     1                 ' Choose a different model and re start '
                  stop
            endif
            if (idbg.gt.0) write(*,*) ' it,cc,ang[1,2,3]; ',
     1           it(i),cc(i),
     +                   ang1(i),ang2(i),ang3(i)
            if (idbg.gt.0) write(*,*) ' a1 a2 a3: ',aa(i),aa1,aa2
      end do

c     next line leftover from old dssim code
c     to be cleaned up
      itrans=0
c      if (idbg.gt.-1) write(*,*) ' Use trans after simulation ? ', 
c     1     itrans


      
      if (idrawopt.eq.1) then
         
         if (idbg.gt.0) write(*,*) 'READING NSCORE OPTIONS'
         
         read(lin,*,err=98) zmin,zmax
         if (idbg.gt.0) write(*,*) ' data limits (tails) = ',zmin,zmax
         
         read(lin,*,err=98) ltail,ltpar
         if (idbg.gt.0) write(*,*) ' lower tail option = ',ltail,ltpar
         
         read(lin,*,err=98) utail,utpar
         if (idbg.gt.0) write(*,*) ' upper tail option = ',utail,utpar
         
         
         
      end if
      
      
c 
c  End of reading in for trans after direct sequential simulation
c  


      close(lin)

c
c Perform some quick error checking for grid size and tail option:
c
      testfl = .false.
      if(nx.gt.MAXX.or.ny.gt.MAXY.or.nz.gt.MAXZ) then
            if (idbg.gt.-1) write(*,*) 'ERROR: available grid size: ',
     1        MAXX,MAXY,MAXZ
            if (idbg.gt.-1) write(*,*) '       you have asked for : ',
     1           nx,ny,nz
            testfl = .true.
      end if
      if(itrans.eq.1) then 
        if(ltail.ne.1.and.ltail.ne.2) then
            if (idbg.gt.-1) write(*,*) 'ERROR invalid lower tail 
     1          option ',ltail
            if (idbg.gt.-1) write(*,*) '      only allow 1 or 2 - 
     1           see manual '
            testfl = .true.
        endif
        if(utail.ne.1.and.utail.ne.2.and.utail.ne.4) then
            if (idbg.gt.-1) write(*,*) 
     1          'ERROR invalid upper tail option ',ltail
            if (idbg.gt.-1) write(*,*) 
     1           '      only allow 1,2 or 4 - see manual '
            testfl = .true.
        endif
        if(utail.eq.4.and.utpar.lt.1.0) then
            if (idbg.gt.-1) write(*,*) 
     1          'ERROR invalid power for hyperbolic tail',utpar
            if (idbg.gt.-1) write(*,*) 
     1           '      must be greater than 1.0!'
            testfl = .true.
        endif
        if(ltail.eq.2.and.ltpar.lt.0.0) then
            if (idbg.gt.-1) write(*,*) 
     1          'ERROR invalid power for power model',ltpar
            if (idbg.gt.-1) write(*,*) 
     1           '      must be greater than 0.0!'
            testfl = .true.
        endif
        if(utail.eq.2.and.utpar.lt.0.0) then
            if (idbg.gt.-1) write(*,*) 
     1          'ERROR invalid power for power model',utpar
            if (idbg.gt.-1) write(*,*) 
     1           '      must be greater than 0.0!'
            testfl = .true.
        endif
      endif
      if(testfl) stop


c
c If conditional simulation,  check to make sure the data file exists if
c If unconditional simulation, set necessary parameters 
c
      nd = 0
      av = 0.0
      ss = 0.0
      if(icond.ge.1) then 
        inquire(file=datafl,exist=testfl)
        if(.not.testfl) then
             if (idbg.gt.-1) write(*,*) 
     1          'WARNING data file ',datafl,' does not exist!'
             if (idbg.gt.-1) write(*,*) 
     1            'If you want to create conditional simulation',   
     +                  'please check whether you have specified ', 
     +                  'the correct filename '
	     if (idbg.gt.-1) write(*,*) 
     1            'If you want to create an unconditional simulation ',
     +                  'please reset icond = 0'
c	      stop
        end if
      else
        inquire(file=datafl,exist=testfl) 
        datafl='nodata'
	if(testfl) then
	   if (idbg.gt.-1) write(*,*) 
	   if (idbg.gt.-1) write(*,*) 
     +          'WARNING: You are doing unconditional simulation',
     +          ' the filename of conditioning data has been reset',
     +          ' to be nodata. Next time, please set it to nodata',
     +          ' if you are doing unconditioning simulation.' 
	endif 
	ndmin  = 0
        ndmax  = 0 
c     WHY SSTRAT = 1 ?
        sstrat = 1
      end if 		

      if(icond.eq.2) then
c     Condition to VOLUME data only
         ndmin  = 0
         ndmax  = 0
         sstrat = 1
      endif 
c
c Read in the conditioning data for the simulation: 
c 
c

c
c Now, read the data if conditional simulation is specified:
c
      
      inquire(file=datafl,exist=testfl)
      if (testfl.and.((icond.eq.1).OR.(icond.eq.2))) then
         if (idbg.gt.0) write(*,*) 'Reading input data'
         open(lin,file=datafl,status='OLD')
         read(lin,*,err=99)
         read(lin,*,err=99) nvari
         do i=1,nvari
            read(lin,*,err=99)
         end do
         if(ixl.gt.nvari.or.iyl.gt.nvari.or.izl.gt.nvari.or.
     +        ivrl.gt.nvari.or.isecvr.gt.nvari.or.iwt.gt.nvari) then
            if (idbg.gt.-1) write(*,*) 
     +           'ERROR: you have asked for a column number'
            if (idbg.gt.-1) write(*,*) 
     +           '       greater than available in file'
c            stop
         end if
         
         
         if (idbg.gt.1) write(*,*) 'read data '
c     
c     Read all the conditioning data until the end of the file:
c     
         twt = 0.0
         nd  = 0
         nt  = 0
 5       read(lin,*,end=6,err=99) (var(j),j=1,nvari)
         if(var(ivrl).lt.tmin.or.var(ivrl).ge.tmax) then
            nt = nt + 1
            go to 5
         end if
         nd = nd + 1
         
         if(nd.gt.MAXDAT) then
            if (idbg.gt.-1) write(*,*) 
     +           ' ERROR exceeded MAXDAT - check inc file'
            stop
         end if
c     
c     Acceptable data, assign the value, X, Y, Z coordinates, and weight:
c     
         vr(nd) = var(ivrl)
c     vr(nd)=2.928
         if(ixl.le.0) then
            x(nd) = xmn
         else
            x(nd) = var(ixl)
         endif
         if(iyl.le.0) then
            y(nd) = ymn
         else
            y(nd) = var(iyl)
         endif
         if(izl.le.0) then
            z(nd) = zmn
         else
            z(nd) = var(izl)
         endif
         
         
         if(iwt.le.0) then
            wt(nd) = 1.0
         else
            wt(nd) = var(iwt)
         endif
         
         
         if(isecvr.le.0) then
            sec(nd) = UNEST
         else
            sec(nd) = var(isecvr)
         endif
         
         twt = twt + wt(nd)
         av  = av  + var(ivrl)*wt(nd)
         ss  = ss  + var(ivrl)*var(ivrl)*wt(nd)
         go to 5
 6       close(lin)

      endif
         
c     
c     Read in the VOLUME conditioning data for the simulation: 
c     
c     
c     
c     First read the summary of the volume data
c     
      if ((icond.eq.1).OR.(icond.eq.3)) then

         if (idbg.gt.0) write(*,*) '----------------------------'
         inquire(file=volsumfl,exist=testfl)
         if(testfl) then
            if (idbg.gt.0) write(*,*) 
     +           'Reading SUMMARY VOLUME volume data'
            open(lin,file=volsumfl,status='OLD')
         endif
c     READ THE FIRST COMMENTED LINES
         read(lin,*,err=99)
         read(lin,*,err=99) nvari
         do i=1,nvari
            read(lin,*,err=99)
         end do
c     READ THE ACTUAL DATA
         nvol = 0
         do i=1,MAXVOLS
            vvtmp=0
c     NEXT LINE TO READ IN UNCERTAINTY
            read(lin,*,iostat = IntVar) ivol,nvoldata,cumsum,vvtmp
c     NEXT LINE TO NOT(!!!) READ IN UNCERTAINTY
c            read(lin,*,iostat = IntVar) ivol,nvoldata,cumsum
c            vvtmp=0

ccccc            

            if (IntVar.lt.0) then
               exit
            endif
            ndatainvol(i)=nvoldata
            volobs(i)=cumsum
            volvar(i)=vvtmp
            nvol = nvol + 1            
            if (i.gt.MAXVOLS) then
               if (idbg.gt.-1) 
     +              write(*,*) 'You specify more volumes, than assigned
     +              by fortran, please change MAXVOLS=',MAXVOLS
               stop
            end if
            
            if (idbg.ge.4) then
               if (idbg.gt.-1) 
     +              write(*,*) 'ivol,ndatainvol,volobs,volvar=',+
     +              ivol,ndatainvol(i),volobs(i),volvar(i)
            endif
            
         end do
         if (idbg.gt.0) write(*,*) 'READ SUMMARY FILE, nvol=',nvol 
         if (idbg.gt.0) write(*,*) '----------------------------'
         


c +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
c     CHECK IF DATA COVARIANCE FILE IS GIVEN, THEN READ IT
c
         datacovfl='datacov'//'_'//outfl
         inquire(file=datacovfl,exist=testfl)
         if(testfl) then
            if (idbg.gt.(-1)) write(*,*) 
     +           'Reading data covariance from file =',datacovfl
            open(lin,file=datacovfl,status='OLD')
c     READ THE FIRST COMMENTED LINES
            read(lin,*,err=99)
            read(lin,*,err=99) nvari
            do i=1,nvari
               read(lin,*,err=99)
            end do
            k=0
            do i=1,nvol
               do j=1,nvol
                  k=k+1
                  read(lin,*,iostat = IntVar) vvreal
                  datacov(i,j)=vvreal
c                  if (idbg.gt.1)
c     +                 write(*,*) '(ix,iy)=(',i,',',j,')',datacov(i,j)
               enddo
            enddo

         else
            if (idbg.gt.(-1)) then 
               write(*,*) 
     +              'No data covariance from file =',datacovfl 
               write(*,*) 'Using uncorrelated data uncertainty!'
            endif

c     Zero datcov matrix
            do i=1,(nvol)
            do j=1,(nvol)
               datacov(i,j)=0
            enddo
            enddo
c     Uncorrelated data uncertainty / diagonal of datcov matrix
            do i=1,nvol
               datacov(i,i)=volvar(i);
            enddo
            if (idbg.gt.2) then
               do i=1,nvol
                  do j=1,nvol
                     write(*,*) '(ix,iy)=(',i,',',j,')=',datacov(i,j)
                  enddo
               enddo
            endif
         endif
c     
c     Then read the geometry of the volume data
c     

         inquire(file=volgeomfl,exist=testfl)

         if(testfl) then
            if (idbg.gt.1) write(*,*) 
     +           'START - Reading VOLUME GEOMETRY volume data'
            open(lin,file=volgeomfl,status='OLD')
         else
            if (idbg.gt.-1) write(*,*) 'COULD NOT OPEN FILE'                     
         endif
c     READ THE FIRST COMMENTED LINES
         read(lin,*,err=99)
         read(lin,*,err=99) nvari
         do i=1,nvari
            read(lin,*,err=99)
         end do
c     READ THE ACTUAL DATA
         ndinv=0
         ivol_new=1
         iv=1
         
         do i=1,MAXGEOMDATA
            ivolx=0
            ivoly=0
            ivolz=0
            ivoll=0

            read(lin,*,iostat = IntVar) 
     +           ivolx,ivoly,ivolz,ivol_new,ivoll
            
c     CHECK THAT WE AE NOT AT THE END OF A FILE GIVEN BY A BLANK
c     OR MALFORMED LINE
            if ((ivolx.eq.0).and.(ivoly.eq.0).and.(ivolz.eq.0)) then
               if (idbg.gt.0) write(*,*) 'Seems like a blank line'
               if (idbg.gt.0) write(*,*) 
     +              '--> assuming no more data in file'
c               ndinv=ndinv-1
               exit
            endif


c+ (iy1-1)*nx + (iz1-1)*nxy
            
c            if (idbg.gt.-1) write(*,*) '*****',iv,ndinv,ivolx
            
            
c     CHECK IF AT END OF FILE
            if (IntVar.lt.0) then
c     CHECK FOR CONSITENCY WITH SUMMARY FILE
               if (ndatainvol(iv).ne.ndinv) then
                  if (idbg.gt.-1) write(*,*) 
     +                 '  Geo and Sum differ for volume=',iv
                  if (idbg.gt.0) write(*,*) 
     +                 '  ndatainvolume=',ndatainvol(iv)
                  if (idbg.gt.0) write(*,*) '  ndinv=',ndinv
                endif
               if (idbg.gt.1) write(*,*) 
     +               'END - READ GEOMETRY OF VOLUME=',iv,ndinv,
     +              ndatainvol(iv),volobs(iv)
               exit
            endif
c     CHECK IF WE ARE AT A NEW VOLUME NODE

            if (ivol_new.ne.iv) then
c     CHECK FOR CONSITENCY WITH SUMMARY FILE
               if (ndatainvol(iv).ne.ndinv) then
                  if (idbg.gt.-1) write(*,*) 
     +                 'RAYINFO Geometry and Summary',
     +             ' differ for vol=',iv
                  if (idbg.gt.0) write(*,*) 
     +                 'SUM : ndatainvol=',ndatainvol(iv)
                  if (idbg.gt.0) write(*,*) 
     +                 'GEO : ndatainvol=',ndinv
c                  stop '**************'
               endif
               
               if (idbg.ge.4) then
                  if (idbg.gt.0) write(*,*) 
     +                 '    finished reading volume=',iv,ndinv,
     +                 ndatainvol(iv),volobs(iv)
               endif
               iv=ivol_new
               ndinv=1
            else
               ndinv=ndinv+1
            endif
            
            if (ndinv.ge.MAXDINVOL) then
               if (idbg.gt.-1) write(*,*) 
     +              'You specify more data for volume,
     +              than assigned by fortran, please change 
     +              MAXDINVOL=',MAXDINVOL
               stop '*****************'
            end if
            
c            if (idbg.gt.-1) write(*,*) 'ndinv,ivo1lx,ivoly,ivoll,ivol=',+
c     +           ndinv,ndatainvol(ivol),ivolx,ivoly,ivoll,ivol,ivol_new
            
c     ASSIGHN DATA
c     ASSIGN VALUES TO /geometry/ COMMON BLOCK
            volx(iv,ndinv)=ivolx
            voly(iv,ndinv)=ivoly
            volz(iv,ndinv)=ivolz
            voll(iv,ndinv)=ivoll
            testind = .true.
            call getindx(nx,xmn,xsiz,volx(iv,ndinv),ix1,testind)
            call getindx(ny,ymn,ysiz,voly(iv,ndinv),iy1,testind)
            call getindx(nz,zmn,zsiz,volz(iv,ndinv),iz1,testind)
            voli(iv,ndinv) = ix1 + (iy1-1)*nx + (iz1-1)*nxy

         end do
 
         if (idbg.gt.0) write(*,*) 'ndatainvolume=',ndatainvol(iv)
         if (idbg.gt.0) write(*,*) 'ndinv=',ndinv
         
         if (idbg.gt.1) write(*,*) 
     +        'END - READ VOLUME GEOMETRY FILE, nvol=',nvol 
         if (idbg.gt.0) write(*,*) '----------------------------'
         close(lin)

c WRITE DEBUG TO SCREEN         
         if (idbg.ge.4) then
            if (idbg.gt.-1) write(*,*) 
     +           '***************** VOLUME DATA ****************'
            if (idbg.gt.-1) write(*,*) 'volx,voly,volz,voll,voli'
            do ivol=1,nvol
               write(*,43) ivol,ndatainvol(ivol),volobs(ivol)
 43            format('Volume=',i4,' nd=',i6,' v_obs=',f7.4)
               do idata=1,ndatainvol(ivol)
                  write(*,44) ivol,volx(ivol,idata),voly(ivol,idata),
     +                 volz(ivol,idata),voll(ivol,idata),
     +                 voli(ivol,idata)
 44               format(i8,' ',f6.4,' ',f6.4,' ',f6.4,' ',f6.4,' ',i8)
               enddo
            enddo
            if (idbg.gt.-1) write(*,*) 
     +           '**********************************************'
         endif


c
c COMPUTE REFERENCE VELOCITY 
c     
         
         do i=1,nvol
            volobs_ref(i)=0;
            do j=1,ndatainvol(i)
              volobs_ref(i) = 
     +              volobs_ref(i) + voll(i,j)*skgmean
c               if (i.eq.33) then 
c                  if (voll(i,j).gt.0) write(*,*) '',voll(i,j)
c               endif                          
            enddo
c    write(*,*) 'i,vref=',i,volobs_ref(i)

c            if (volobs_ref(i).gt.7) then 
c               write(*,*), '>7--',i,volobs_ref(i)
c            endif
c            if (volobs_ref(i).lt.6) then 
c               write(*,*), '<6--',i,volobs_ref(i)
c            endif


         enddo
     

       
c
c Populate the V matrix containig the geometry if the volume data !!
c


c
c Compute the averages and variances as an error check for the user:
c
            av = av / max(twt,EPSLON)
            ss =(ss / max(twt,EPSLON)) - av * av
            
            if (idbg.gt.0) then
               write(*,   111) nd,nt,av,ss
            endif
            if (idbg.gt.-2) then
               write(ldbg,111) nd,nt,av,ss   
            endif
 111  format(/,' Conditioning Data for VISIM: ', 
     +         'Number of acceptable data = ',i8,/,
     +         '               Number trimmed             = ',i8,/,
     +         '               Weighted Average           = ',f12.4,/,
     +         '               Weighted Variance          = ',f12.4,/)
      endif



c +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
c     CHECK IF MASK FILE IS GIVEN, THEN READ IT
c
         maskfl='mask'//'_'//outfl
         inquire(file=maskfl,exist=testfl)
         if(testfl) then
            if (idbg.gt.-1) write(*,*) 'Using mask:',maskfl

            open(lin,file=maskfl,status='OLD')
            read(lin,*,err=999)
            read(lin,*,err=999) nvari
            do i=1,nvari
               read(lin,*,err=999)
            end do
            do i=1,nxyz
               read(lin,*,iostat = IntVar) tempint
               mask(i)=tempint
            enddo


         else
            do i=1,(nxyz)
               mask(i)=1;
            enddo
c            write(*,*) 'NOT Using mask:',maskfl
         endif




c
c In case the local conditional distribution is obtained from bootstrap (idrawopt=2)
c  read the file that is used in the bootstrap 
c


c      if ((idrawopt .eq. 2).or.(idrawopt .eq. 4)) then
      if (idrawopt.eq. 1) then
         nbt = 0
         twt = 0.0
         av = 0.0
         ss = 0.0
         inquire(file=btfl,exist=testfl)
         if(.not.testfl) then
            write(*,1004) btfl
 1004       format('WARNING bootstrap file ',a40,
     +           ' does not exist!')
            stop
         end if
         
         open(lin,file=btfl,status='OLD')
         read(lin,*,err=999)
         read(lin,*,err=999) nvarbt
         do i=1,nvarbt
            read(lin,*,err=999)
         end do
                         
 55      read(lin,*,end=66,err=999) (var(j),j=1,nvarbt)
         
         
         nbt = nbt + 1
         if(nbt.gt.MAXDAT) then
            if (idbg.gt.-1) write(*,*) 
     +           ' ERROR exceeded MAXDAT for bootstrap'
            stop
         end if
         
         bootvar(nbt) = var(ibt)
         if (ibtw .eq. 0) then 
            bootwt(nbt) = 1.0
         else
            bootwt(nbt) = var(ibtw)
         end if
         
         twt = twt + bootwt(nbt)
         av  = av  + bootvar(nbt)*bootwt(nbt)
         ss  = ss  + bootvar(nbt)*bootvar(nbt)*bootwt(nbt)
         
         go to 55
 66      close(lin)
         
         
            btmean = av / max(twt,EPSLON)
            btvar = (ss / max(twt,EPSLON)) - btmean*btmean
            if (idbg.gt.-1) then
	            write(ldbg,1111) nbt,btmean,btvar
	            write(*,   1111) nbt,btmean,btvar
	    endif	
	            

 1111    format(/,' Bootstrap Data for VISIM: ', 
     +       'Number of bootstrap data = ',i8,/,
     +       '        Bootstrap Weighted Average           = ',f12.4,/,
     +       '        Bootstrap Weighted Variance          = ',f12.4)

	    call sortem(1,nbt,bootvar,1,bootwt,c,d,e,f,g,h)

	    sumwt = 0.0
	    do i = 1, nbt
		bootwt(i) = bootwt(i)/(twt+1)
		sumwt = sumwt + bootwt(i)
		bootcdf(i) = sumwt 
	    end do

      end if	



c
c Read secondary attribute model if lvm, exdr and colc kriging is used:
c Please note that secondary variable file must be gridded with secondary
c variable values at each grid node. 
 
      if(ktype.ge.2) then
         if (idbg.gt.-1) write(*,*) 'Reading secondary attribute file'
         inquire(file=lvmfl,exist=testfl)
         if(.not.testfl) then
            write(*,104) lvmfl
 104        format('WARNING secondary attribute file ',a40,
     +           ' does not exist!')
            stop 
         end if
         open(llvm,file=lvmfl,status='OLD')
         read(llvm,*,err=97)
         read(llvm,*,err=97) nvaril
         do i=1,nvaril
            read(llvm,*,err=97)
         end do
         index = 0
         
         av = 0.0
         ss = 0.0
         do iz=1,nz
            do iy=1,ny
               do ix=1,nx
                  index = index + 1
                  read(llvm,*,err=97) (var(j),j=1,nvaril)
                  lvm(index) = var(icollvm)
                  sim(index) = real(index)
                  av = av + var(icollvm)
                  ss = ss + var(icollvm)*var(icollvm)
               end do
            end do
         end do
         av = av / max(real(nxyz),1.0)
         ss =(ss / max(real(nxyz),1.0)) - av * av
         write(ldbg,112) nxyz,av,ss
         write(*,   112) nxyz,av,ss
 112     format(/,' Sec Data: Number of data             = ',i8,/,
     +        '                 Equal Weighted Average     = ',f12.4,/,
     +        '                 Equal Weighted Variance    = ',f12.4,/)
         
         
c     c When using kriging with locally varying mean (LVM, ktype=2), the
c     c array lvm() denotes the mean m(u) at every grid node, while sec() 
c     c denotes the mean at sample data location u_{alpha}.  In order to do
c     c kriging, we need the mean m(u_{alpha}) at sample data location
c     c u_{alpha}. In lvm, m(u_{alpha}) is usually not given
c     c at sample data location, but m(u) is available at a regular 
c     c grid. That is why we copy nearest m(u) to  m(u_{alpha}) 
c     c given in the lvmfl file. 
         
         if(ktype.eq.2) then
            do i=1,nd
               call getindx(nx,xmn,xsiz,x(i),ix,testind)
               call getindx(ny,ymn,ysiz,y(i),iy,testind)
               call getindx(nz,zmn,zsiz,z(i),iz,testind)
               index = ix + (iy-1)*nx + (iz-1)*nxy
               sec(i) = lvm(index)
c     
c     Calculation of residual moved to krige subroutine: vr(i)=vr(i)-sec(i)
c     
            end do
         end if
         
         
         
c     c When using kriging with external drift (EXDR, ktype=3), lvm()
c     c usually denotes a smoothly varying secondary variable at grid 
c     c locations u given in the file lvmfl, while sec() denotes  sec. 
c     c variable at sample data location u_{alpha}. In order to do kriging
c     c with EXDR, you need to know the sec. variable information both at 
c     c grid node u and sample data location u_{alpha}. In the case when sec.
c     c variable info. sec() at sample data location u_{alpha} is not read
c     c from the sample data file datafl, i.e. (sec(i)=UNEST), it will copy
c     c the secondary variable information from the nearest grid node to this
c     c sample location.
         
         if(ktype.eq.3) then
            do i=1,nd
               if(sec(i).eq.UNEST) then
                  call getindx(nx,xmn,xsiz,x(i),ix,testind)
                  call getindx(ny,ymn,ysiz,y(i),iy,testind)
                  call getindx(nz,zmn,zsiz,z(i),iz,testind)
                  index = ix + (iy-1)*nx + (iz-1)*nxy
                  sec(i) = lvm(index)
               end if
            end do
         end if
         
         
c     
c     In the case of collocated kriging(COLC, ktype=4), we need secondary
c     variable information at the gridded node. It must be provided by the
c     sec. attribute model file lvmfl at each grid node. 
c     
         
         
      end if
      
      
      return

c
c Error in an Input File Somewhere:
c
 97   stop 'ERROR in secondary data file!'
 98   stop 'ERROR in parameter file!'
 99   stop 'ERROR in data file!'
 999  stop 'ERROR in bootstrap file!'
      end


