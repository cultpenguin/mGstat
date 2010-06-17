c%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c                                                                     %
c Copyright (C) 2000, The Board of Trustees of the Leland Stanford    %
c Junior University.  All rights reserved.                            %
c                                                                     %
c The programs in GSLIB are distributed in the hope that they will be %
c useful, but WITHOUT WARRENTY. No author or distributor accepts      %
c responsability to anyone for the consequences of using them of for  %
c whether they serve any particular purpose or work at all, unless he %
c says so in writing. Everyone is granted permission to copy, modify  % 
c and redistribute the programs in GSLIB, but only under the          %    
c condition that this notice remain intact.                           %
c                                                                     %
c%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

c----------------------------------------------------------------------
c
c                Single Normal Equation Simulation
c                *********************************
c
c The program is executed with no command line arguments. The user will 
c be prompted for the name of a parameter file. The algorithm is
c described in the SCRF 2000 paper "sequential simulation
c drawing structures from training image".
c
c The sizes (number of blocks) of the training image and of the 
c simulation grid can be different, but their resolutions (block size)
c must be the same.
c
c The output file will be a GEOEAS file containing the simulated values.
c The file is ordered by x, y, z, and THEN simulation (i.e., x cycles
c fastest, THEN y, THEN z, THEN simulation number).
c		Code developped and written by Sebastien Strebelle.
c
c
c----------------------------------------------------------------------


      MODULE parameter
      IMPLICIT NONE
      SAVE
     
      ! Declare constant variables

      ! Input/output units used
      INTEGER, PARAMETER :: lin=1, lout=2, lun=3, ldbg=4

      ! Program version
      REAL, PARAMETER :: VERSION=4.000

      ! Maximum number of categories (classes of values)
      INTEGER, PARAMETER :: MAXCUT=2

      ! Maximum dimensions of the simulation grid
      INTEGER, PARAMETER :: MAXX=300, MAXY=300, MAXZ=20

      ! Maximum dimensions of the training image
      INTEGER, PARAMETER :: MAXXTR=250, MAXYTR=250, MAXZTR=20
      
      ! Maximum dimensions of the data search neighborhood (odd numbers)
      INTEGER, PARAMETER :: MAXCTX =71, MAXCTY=71, MAXCTZ=21

      INTEGER, PARAMETER :: MAXXY=MAXX*MAXY, MAXXYTR=MAXXTR*MAXYTR
      INTEGER, PARAMETER :: MAXXYZ=MAXXY*MAXZ
      INTEGER, PARAMETER :: MAXXYZTR=MAXXYTR*MAXZTR
      INTEGER, PARAMETER :: MAXCTXY=MAXCTX*MAXCTY
      INTEGER, PARAMETER :: MAXCTXYZ=MAXCTXY*MAXCTZ

      ! Maximum number of original sample data
      INTEGER, PARAMETER :: MAXDAT=100000

      ! Maximum number of conditioning nodes
      INTEGER, PARAMETER :: MAXNOD=100

      ! Maximum number of multiple grids
      INTEGER, PARAMETER :: MAXMULT=5

      ! Minimum correction factor in the servosystem (if used)
      REAL, PARAMETER :: MINCOR=1.0

      REAL, PARAMETER :: EPSILON=1.0e-20, DEG2RAD=3.141592654/180.0
      INTEGER, PARAMETER :: UNEST=-99
      
      
      ! Variable declarations
      
      ! Data locations
      REAL, DIMENSION(MAXDAT) :: x, y, z
      
      ! Data values
      INTEGER, DIMENSION(MAXDAT) :: vr
      
      ! Number of original sample data
      INTEGER :: nd
      
      ! Number of categories
      INTEGER :: ncut
      
      ! Category thresholds
      INTEGER, DIMENSION(MAXCUT) :: thres
      
      ! Target global pdf and target vertical proportion curve
      REAL, DIMENSION(MAXCUT) :: pdf
      REAL, DIMENSION(MAXZ,MAXCUT) :: vertpdf 
      
      ! Use target vertical proportion curve (0=no, 1=yes)
      INTEGER :: ivertprop
      
      ! Number of nodes simulated in each category for the full grid
      ! and for each horizontal layer    
      INTEGER, DIMENSION(MAXCUT) :: nodcut
      INTEGER, DIMENSION(MAXZ,MAXCUT) :: vertnodcut

      ! Dimension specifications of the simulation grid
      INTEGER :: nx, ny, nz, nxy, nxyz
      REAL :: xmn, xsiz, ymn, ysiz, zmn, zsiz
      
      ! Training images
      INTEGER, DIMENSION (MAXXTR,MAXYTR,MAXZTR,MAXMULT) :: trainim
      
      ! Dimensions of the training images
      INTEGER, DIMENSION (MAXMULT) :: nxtr, nytr, nztr, nxytr, nxyztr
      
      ! Integer debugging level (0=none,1=normal,3=serious)
      INTEGER :: idbg
      
      ! Use servosystem (0=no,1=yes)            
      INTEGER :: iservo
         
      ! Servosystem correction
      REAL, DIMENSION (MAXMULT) :: servocor
      
      ! Number of realizations to generate
      INTEGER :: nsim
      
      ! Realization and number of conditioning data retained
      INTEGER, DIMENSION (MAXX,MAXY,MAXZ) :: simim, numcd
      
      ! Parameters defining the search ellipse
      REAL, DIMENSION (MAXMULT) :: radius, radius1, radius2
      REAL, DIMENSION (MAXMULT) :: sanis1, sanis2
      REAL, DIMENSION (MAXMULT) :: sang1, sang2, sang3
      REAL, DIMENSION (3,3) :: rotmat
      
      ! Number of grid node locations in data search 
      ! neighborhood (no search tree)
      INTEGER :: nlsearch
      
      ! Relative grid node coordinates in data search 
      ! neighborhood 
      INTEGER, DIMENSION (MAXCTXYZ) :: ixnode,iynode,iznode
      
      ! Number of conditioning data
      INTEGER :: nodmax
      
      ! Number of conditioning data per octant
      INTEGER :: noct
      
      ! Minimum number of replicates for training cpdf to be retained
      INTEGER :: cmin
      
      ! Total number of multiple grids, number of multiple grids
      ! simulated using a search tree
      INTEGER :: nmult, streemult
      
      ! Current multiple grid number
      INTEGER :: ncoarse
      
      ! Dimensions of the current multiple grid
      INTEGER :: nxcoarse, nycoarse, nzcoarse
      INTEGER :: nxycoarse, nxyzcoarse
      
      ! Number of nodes in the data template (with search tree)
      INTEGER :: nltemplate
      
      ! Relative node coordinates in the data template (with search tree)
      INTEGER, DIMENSION (MAXNOD) :: ixtemplate,iytemplate,iztemplate
      
      ! Number of times a conditioning data was located at each 
      ! template data location and number of times this data was dropped.
      INTEGER, DIMENSION (MAXNOD) :: nlcd, nldropped
      
      ! Number of nodes simulated in the current multiple grid
      INTEGER :: nodsim
      
      ! Relative coordinates and values of conditioning data
      INTEGER, DIMENSION (MAXNOD) :: cnodex,cnodey,cnodez,cnodev
      
      ! Number of conditioning data retained
      INTEGER :: ncnode
      
      ! Index of the nodes successively visited in the current multiple grid
      INTEGER, DIMENSION(MAXXYZ) :: order
      
      CONTAINS
      
 
      SUBROUTINE ReadParm
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
      
      ! Declare local variables
      REAL, DIMENSION(10) :: var
      INTEGER, DIMENSION(2) :: seed
      CHARACTER (LEN=30) :: datafl, outfl, dbgfl, templatefl
      CHARACTER (LEN=30) :: vertpropfl
      CHARACTER (LEN=30), DIMENSION(MAXMULT) :: trainfl
      CHARACTER (LEN=40) ::  str
      LOGICAL :: testfl
      INTEGER :: nvari, i, j, k, ioerror
      INTEGER :: icut, ntr, ix, iy, iz, ic, imult
      INTEGER :: ixl, iyl, izl, ivrl
      INTEGER, DIMENSION (MAXMULT) :: ivrltr
      REAL :: servo      
      INTEGER :: ixv
      REAL, DIMENSION(MAXCUT) :: sampdf, trpdf

!
! Note VERSION number:
!
      WRITE(*,9999) VERSION
 9999 format(/' SNESIM Version: ',f5.3/)
!
! Get the name of the parameter file - try the default name if no input:
!
      WRITE(*,*) 'Which parameter file do you want to use?'
      READ (*,'(a40)') str
      IF(str(1:1)==' ')str='snesim.par                               '
      INQUIRE(file=str,exist=testfl)
      IF(.not.testfl) THEN
         WRITE(*,*) 'ERROR - the parameter file does not exist,'
         WRITE(*,*) '        check for the file and try again  '
         WRITE(*,*)
         IF(str(1:20)=='snesim.par           ') THEN
            WRITE(*,*) '        creating a blank parameter file'
            CALL MakePar
            WRITE(*,*)
         END IF
         STOP
      END IF
      OPEN(lin,file=str,status='OLD')
!
! Find Start of Parameters:
!
 1    READ(lin,'(a4)',end=98) str(1:4)
      IF(str(1:4)/='STAR') GO TO 1
!
! Read Input Parameters:
!
      READ(lin,'(a30)',err=98) datafl
      CALL chknam(datafl,30)
      WRITE(*,*) ' data file = ',datafl

      READ(lin,*,err=98) ixl,iyl,izl,ivrl
      WRITE(*,*) ' input columns = ',ixl,iyl,izl,ivrl

      READ(lin,*,err=98) ncut
      WRITE(*,*) ' number of categories = ',ncut
      IF(ncut>MAXCUT) THEN
         WRITE(*,*) 'ERROR: maximum number of categories: ',MAXCUT
         WRITE(*,*) '       you have asked for : ',ncut
      END IF

      READ(lin,*,err=98) (thres(icut), icut=1,ncut)
      WRITE(*,*) ' categories = ', (thres(icut), icut=1,ncut)

      READ(lin,*,err=98) (pdf(icut), icut=1,ncut)
      WRITE(*,*) ' target pdf = ', (pdf(icut), icut=1,ncut)

      READ(lin,*,err=98) ivertprop
      WRITE(*,*) ' use target vertical proportions = ',ivertprop
      IF(ivertprop>1) THEN
         STOP 'ERROR: ivertprop must be 0 or 1'
      END IF

      READ(lin,'(a30)',err=98) vertpropfl
      CALL chknam(vertpropfl,30)
      WRITE(*,*) ' vertical proportions file = ',vertpropfl
      INQUIRE(file=vertpropfl,exist=testfl)
      IF(ivertprop>0.AND.(.NOT.testfl)) THEN
         WRITE(*,*) 'ERROR - the vertical proportions file does '
         WRITE(*,*) 'not exist, check for the file and try again  '
         STOP
      END IF

      READ(lin,*,err=98) iservo,servo
      WRITE(*,*) ' servosystem correction = ',iservo,servo
      IF(iservo/=0.AND.iservo/=1) THEN
         STOP 'ERROR: iservo must be 0 or 1'
      END IF
      IF(iservo==1.AND.servo<0) THEN  
         STOP 'ERROR: correction factor must be positive !'
      END IF
      IF(iservo==1.AND.servo>1) THEN
         STOP 'ERROR: correction factor must be less than 1.0 !'
      END IF

      READ(lin,*,err=98) idbg
      WRITE(*,*) ' debugging level = ',idbg

      READ(lin,'(a30)',err=98) dbgfl
      CALL chknam(dbgfl,30)
      WRITE(*,*) ' debugging file = ',dbgfl

      READ(lin,'(a30)',err=98) outfl
      WRITE(*,*) ' output file = ',outfl

      READ(lin,*,err=98) nsim
      WRITE(*,*) ' number of realizations = ',nsim

      READ(lin,*,err=98) nx,xmn,xsiz
      WRITE(*,*) ' X grid specification = ',nx,xmn,xsiz

      READ(lin,*,err=98) ny,ymn,ysiz
      WRITE(*,*) ' Y grid specification = ',ny,ymn,ysiz

       READ(lin,*,err=98) nz,zmn,zsiz
      WRITE(*,*) ' Z grid specification = ',nz,zmn,zsiz

      IF(nx>MAXX.or.ny>MAXY.or.nz>MAXZ) THEN
         WRITE(*,*) 'ERROR: available grid size: ',MAXX,MAXY,MAXZ
         WRITE(*,*) '       you have asked for : ',nx,ny,nz
         STOP
      END IF
      nxy  = nx*ny
      nxyz=nxy*nz
      
      READ(lin,*,err=98) ixv
      WRITE(*,*) ' random number seed = ',ixv
      
      ! Initialize the random seed of the simulation:
      seed(1)=ixv
      seed(2)=ixv+1
      CALL random_seed(PUT=seed(1:2))
      
      READ(lin,'(a30)',err=98) templatefl
      CALL chknam(templatefl,30)
      WRITE(*,*) ' data template file = ',templatefl

      READ(lin,*,err=98) nodmax
      WRITE(*,*) ' maximum conditioning data = ',nodmax
      IF(nodmax.gt.MAXNOD) THEN
         WRITE(*,*) 'ERROR: maximum available cond. data: ',MAXNOD
         WRITE(*,*) '       you have asked for :  ',nodmax
         STOP
      END IF

      READ(lin,*,err=98) noct
      WRITE(*,*) ' maximum conditioning data per octant= ',noct

      READ(lin,*,err=98) cmin
      WRITE(*,*) ' min. number of replicates = ',cmin

      READ(lin,*,err=98) nmult, streemult
      WRITE(*,*) ' multiple grid simulation = ',nmult,streemult
      IF(nmult>MAXMULT) THEN
         WRITE(*,*) 'ERROR: maximum number of mult. grids: ',MAXMULT
         WRITE(*,*) '       you have asked for :  ',nmult
         STOP
      END IF
      
      IF(streemult>nmult) THEN
       WRITE(*,*) 'ERROR: the number of grids using the search tree'
       WRITE(*,*) 'must be less than the total number of mult. grids.'
       STOP
      END IF


! Now read the information related to each multiple grid. 
! If only one training image is provided in the parameter file,
! this single image will be used for all multiple grids.
      
      DO imult=nmult,1,-1
        WRITE(*,*) 'Multiple grid ', imult
        READ(lin,'(a30)',IOSTAT=ioerror) trainfl(imult)
        IF(ioerror<0.AND.imult==nmult) THEN
          STOP 'ERROR in parameter file!'
        ELSE IF(ioerror<0) THEN
          trainfl(imult)=trainfl(nmult)
          WRITE(*,*) ' training image file = ',trainfl(imult)
          nxtr(imult)=nxtr(nmult)
          nytr(imult)=nytr(nmult)
          nztr(imult)=nztr(nmult)
          WRITE(*,*) ' training grid dimensions = ',
     + 	                 nxtr(imult),nytr(imult),nztr(imult)
          ivrltr(imult)=ivrltr(nmult)
          WRITE(*,*) ' column for variable = ',ivrltr(imult)
          radius(imult)=radius(nmult)
          radius1(imult)=radius1(nmult)
          radius2(imult)=radius2(nmult)
          WRITE(*,*) ' data search neighborhood radii = ',radius(imult),
     +                 radius1(imult),radius2(imult)
          sang1(imult)=sang1(nmult)
          sang2(imult)=sang2(nmult)
          sang3(imult)=sang3(nmult)
          WRITE(*,*) ' search anisotropy angles = ',sang1(imult),
     +                 sang2(imult),sang3(imult)
        ELSE
          CALL chknam(trainfl(imult),30)
          WRITE(*,*) ' training image file = ',trainfl(imult)

          READ(lin,*,err=98) nxtr(imult), nytr(imult), nztr(imult)
          WRITE(*,*) ' training grid dimensions = ',
     + 	           nxtr(imult),nytr(imult),nztr(imult)

          READ(lin,*,err=98) ivrltr(imult)
          WRITE(*,*) ' column for variable = ',ivrltr(imult)
      
          READ(lin,*,err=98) radius(imult),radius1(imult),radius2(imult)
          WRITE(*,*) ' data search neighborhood radii = ',radius(imult),
     +                 radius1(imult),radius2(imult)

          READ(lin,*,err=98) sang1(imult),sang2(imult),sang3(imult)
          WRITE(*,*) ' search anisotropy angles = ',sang1(imult),
     +                 sang2(imult),sang3(imult)
        END IF
      
        IF(nxtr(imult)>MAXXTR.or.nytr(imult)>MAXYTR) THEN
          WRITE(*,*) 'ERROR: available train. grid size: ',
     +              MAXXTR,MAXYTR, MAXZTR
          WRITE(*,*) '       you have asked for : ',
     +              nxtr(imult),nytr(imult),nztr(imult)
          STOP
        END IF
        nxytr(imult) = nxtr(imult)*nytr(imult)
        nxyztr(imult)=nxytr(imult)*nztr(imult)

        IF(radius(imult)<EPSILON.OR.radius1(imult)<EPSILON.
     +                         OR.radius2(imult)<EPSILON) 
     +     STOP 'radius must be greater than zero'
        sanis1(imult)=radius1(imult)/radius(imult)
        sanis2(imult)=radius2(imult)/radius(imult)
     
      END DO

!
! Now, read the data if the file exists:
!
      INQUIRE(file=datafl,exist=testfl)
      IF(.NOT.testfl) THEN
         WRITE(*,*) 'WARNING data file ',datafl,' does not exist!'
         WRITE(*,*) '   - Hope your intention was to create an ',
     +                       'unconditional simulation'
      nd=0
      ELSE     
         WRITE(*,*) 'Reading input data'
         nodcut(1:ncut)=0            
         OPEN(lin,file=datafl,status='OLD')
         READ(lin,*,err=99)
         READ(lin,*,err=99) nvari
         DO i=1,nvari
            READ(lin,*,err=99)
         END DO
         IF(ixl>nvari.OR.iyl>nvari.OR.izl>nvari.OR.ivrl>nvari) THEN
            WRITE(*,*) 'ERROR: you have asked for a column number'
            WRITE(*,*) '       greater than available in file'
            STOP
         END IF
!
! Read all the data until the end of the file:
! nd: number of data read in the data file.
!
         nd=0              
         DO  
            READ(lin,*,IOSTAT=ioerror) (var(j),j=1,nvari)
            IF(ioerror<0) EXIT
            nd=nd+1
      IF(nd>MAXDAT) STOP' ERROR exceeded MAXDAT - check source file'
!
! Acceptable data, assign the value, X, Y coordinates:
! x,y: vectors of data coordinates
! vr: vector of data values
!
            DO icut=1,ncut
               IF(nint(var(ivrl))==thres(icut)) THEN
                  vr(nd)=icut
                  nodcut(icut)=nodcut(icut)+1
                  EXIT
               END IF
            END DO
            x(nd)=xmn
            y(nd)=ymn 
            z(nd)=zmn 
            IF(ixl>0) x(nd)=var(ixl)
            IF(iyl>0) y(nd)=var(iyl)
            IF(izl>0) z(nd)=var(izl)
         END DO
         CLOSE(lin)
      END IF
!
! Compute the sample category proportions as an error check for the user
!
      WRITE(*,*) ' Number of acceptable data = ', nd
      IF(nd>0) THEN
         sampdf(1:ncut)=real(nodcut(1:ncut))/real(nd)
         DO icut=1,ncut
            WRITE(*,111) icut, sampdf(icut)
111         format(/,' Sample proportion of category ',
     +                      i4,' : ',f6.4) 
         END DO
      END IF

!
! Now, read the target vertical proportions if used:
!
      WRITE(*,*)
      IF(ivertprop>0) THEN
         WRITE(*,*) 'Reading target vertical proportions'
         OPEN(lin,file=vertpropfl,status='OLD')
         READ(lin,*,err=92)
         READ(lin,*,   err=92) nvari
         DO i=1,nvari
            READ(lin,*,err=92)
         END DO
         IF(ncut/=nvari) THEN
            WRITE(*,*) 'ERROR: the vertical proportion file should'
            WRITE(*,*) '       have ',ncut, 'columns'
            STOP
         END IF
         
         iz = 0
         DO
           READ(lin,*, IOSTAT=ioerror) (var(j),j=1,ncut)
           IF(ioerror<0) EXIT
           iz=iz+1
           IF(iz>nz) THEN
             WRITE(*,*) ' ERROR exceeded nz ' 
             WRITE(*,*) ' Target vertical proportion not compatible'
             WRITE(*,*) ' with simulation grid'
             STOP
           END IF
           vertpdf(iz,1:ncut)=var(1:ncut)
         END DO
         CLOSE(lin)
      END IF

!
! Now, read the training images if the files exist:
!
      DO imult=nmult,1,-1
        INQUIRE(file=trainfl(imult),exist=testfl)
        IF(.NOT.testfl) THEN
          STOP 'Error in training image file'
        ELSE   
          WRITE(*,*) 'Reading training image ',imult
          OPEN(lin,file=trainfl(imult),status='OLD')
          READ(lin,*,err=97)
          READ(lin,*,err=97) nvari
          DO i=1,nvari
            READ(lin,*,err=97)
          END DO
          IF(ivrltr(imult)>nvari) THEN
            WRITE(*,*) 'ERROR: you have asked for a column number'
            WRITE(*,*) '       greater than available in file'
            STOP
          END IF
!
! Read all the data until the end of the training file:
! ntr: number of data read in the training file.
!
          ntr=0
          trpdf(1:ncut)=0.0
          DO
            READ(lin,*, IOSTAT=ioerror) (var(j),j=1,nvari)
            IF(ioerror<0) EXIT
            ntr=ntr+1
          IF(ntr>nxyztr(imult)) STOP ' ERROR exceeded nxyztr - 
     +                                 check inc file'
            iz=1+(ntr-1)/nxytr(imult)
            iy=1+(ntr-(iz-1)*nxytr(imult)-1)/nxtr(imult)
            ix=ntr-(iz-1)*nxytr(imult)-(iy-1)*nxtr(imult)
            DO icut=1,ncut
              IF(nint(var(ivrltr(imult)))==thres(icut)) THEN
                trainim(ix,iy,iz,imult)=icut
                trpdf(icut)=trpdf(icut)+1
                EXIT
              END IF
            END DO
          END DO
          CLOSE(lin)
        END IF
!
! Calculate the correction parameter of the servosystem:
!
        trpdf=trpdf/nxyztr(imult)
        IF(iservo==1) THEN
          servocor(imult)=
     +       max((maxval(100*abs(trpdf-pdf))/MINCOR)**servo, 1.5)
          WRITE(*,*) 'Correction parameter = ',servocor(imult)
        ELSE
          servocor(imult)=0.0
        END IF
      END DO
      
!
! Now, read the file defining the data template if it exists:
!
      INQUIRE(file=templatefl,exist=testfl)
      IF(.NOT.testfl) THEN
         STOP 'Error in data template file'
      ELSE   
         WRITE(*,*) 'Reading data template file'
         OPEN(lin,file=templatefl,status='OLD')
         READ(lin,*,err=96)
         READ(lin,*,err=96) nvari
         DO i=1,nvari
            READ(lin,*,err=96)
         END DO
         IF(nvari/=3) STOP 'ERROR: the number of columns should be 3'
!
! Read all the data locations until the end of the training file:
! nltemplate: number of data locations in the template.
!
         nltemplate=0
         DO
            READ(lin,*, IOSTAT=ioerror) (var(j),j=1,nvari)
            IF(ioerror<0) EXIT
            nltemplate=nltemplate+1
            IF(nltemplate>MAXNOD) THEN
             STOP 'ERROR exceeded MAXNOD - check source code'
            END IF
            ixtemplate(nltemplate)=nint(var(1))
            iytemplate(nltemplate)=nint(var(2))
            iztemplate(nltemplate)=nint(var(3))
         END DO
         CLOSE(lin)
      END IF

!
! Open the output file:
!
      OPEN(lout,file=outfl,status='UNKNOWN')
      WRITE(lout,110)
 110  format('SNESIM Realizations',/,'2',/,'category',/,
     +            'number of CD retained')
 
!
! Open the debugging file:
!
      IF(idbg>0) THEN
         OPEN(ldbg,file=dbgfl,status='UNKNOWN')
         WRITE(ldbg,120)
 120     format('SNESIM debugging file')
      END IF
 
      RETURN

!
! Error in an Input File Somewhere:
!
 92   STOP 'ERROR in vertical proportions file!'
 96   STOP 'ERROR in data template file!'
 97   STOP 'ERROR in training image file!'
 98   STOP 'ERROR in parameter file!'
 99   STOP 'ERROR in data file!'
      END SUBROUTINE ReadParm

  
      	
      SUBROUTINE MakePar
c-----------------------------------------------------------------------
c
c                      Write a Parameter File
c                      **********************
c
c
c
c-----------------------------------------------------------------------
      OPEN(lun,file='snesim.par',status='UNKNOWN')
      WRITE(lun,10)
 10   format('                  Parameters for SNESIM',/,
     +       '                  ********************',/,/,
     +       'START OF PARAMETERS:')

      WRITE(lun,11)
 11   format('data.dat                      ',
     +       '- file with original data')
      WRITE(lun,12)
 12   format('1  2  3  4                    ',
     +       '- columns for x, y, z, variable')
      WRITE(lun,13)
 13   format('3                             ',
     +       '- number of categories')
      WRITE(lun,14)
 14   format('0   1   2                     ',
     +       '- category codes')
      WRITE(lun,15)
 15   format('0.25  0.25  0.50              ',
     +       '- (target) global pdf')
      WRITE(lun,16)
 16   format('0                             ',
     +       '- use (target) vertical proportions (0=no, 1=yes)')
      WRITE(lun,17)
 17   format('vertprop.dat                  ',
     +       '- file with target vertical proportions')
      WRITE(lun,18)
 18   format('1    0.5                      ',
     +       '- target pdf repro. (0=no, 1=yes), parameter') 
      WRITE(lun,33)
 33   format('0                             ',
     +       '- debugging level: 0,1,2,3')
      WRITE(lun,34)
 34   format('snesim.dbg                    ',
     +       '- debugging file')
      WRITE(lun,35)
 35   format('snesim.out                    ',
     +       '- file for simulation output')
      WRITE(lun,36)
 36   format('1                             ',
     +       '- number of realizations to generate')
      WRITE(lun,37)
 37   format('50    0.5    1.0              ',
     +       '- nx,xmn,xsiz')
      WRITE(lun,38)
 38   format('50    0.5    1.0              ',
     +       '- ny,ymn,ysiz')
       WRITE(lun,39)
 39   format('1     0.5    1.0              ',
     +       '- nz,zmn,zsiz')
      WRITE(lun,50)
 50   format('69069                         ',
     +       '- random number seed')
      WRITE(lun,53)
 53   format('template.dat                  ',
     +       '- file for primary data template')
      WRITE(lun,55)
 55   format('16                            ',
     +       '- max number of conditioning primary data')
      WRITE(lun,56)
 56   format('0                             ',
     +       '- max number of data per octant (0=not used)')
      WRITE(lun,57)
 57   format('20                            ',
     +       '- min number of data events')
      WRITE(lun,58)
 58   format('2     1                       ',
     +       '- number of mult-grids, number with search trees')
      WRITE(lun,60)
 60   format('train.dat                     ',
     +       '- file for training image')
      WRITE(lun,61)
 61   format('100  100  10                  ',
     +       '- training image dimensions: nxtr, nytr, nztr')
      WRITE(lun,62)
 62   format('1                             ',
     +       '- column for training variable')
      WRITE(lun,63)
 63   format('10.0   10.0   5.0             ',
     +       '- maximum search radii (hmax,hmin,vert)')
      WRITE(lun,64)
 64   format('0.0   0.0   0.0               ',
     +       '- angles for search ellipsoid')
      CLOSE(lun)
      RETURN
      END SUBROUTINE MakePar

      END MODULE parameter

c----------------------------------------------------------------------

      MODULE simul
      USE parameter
      IMPLICIT NONE

!      
! This type defines an elementary node of the search tree 
! used to store the training cpdfs prior to the image simulation.
!
! repl: arrays of integers; repl(ccut) indicates the number of replicates
! for which the central value corresponds to the category ccut.
! next: array of pointers; next(icut) points towards the node
! corresponding to an additional conditioning datum assigned 
! to the category icut.
!

      TYPE streenode
         INTEGER, DIMENSION(MAXCUT) ::  repl
         TYPE(streenode), DIMENSION(:), POINTER :: next
      END TYPE streenode



      
      CONTAINS

      SUBROUTINE InitializeSearch (imult)
      IMPLICIT NONE
c-----------------------------------------------------------------------
c
c        Establish a search for nearby nodes in order of closeness
c        *********************************************************
c
c We want to establish a search for nearby nodes in order of closeness 
c as defined by the distance corresponding to the search ellipse.
c
c
c PROGRAM NOTE: The dimensional anisotropy parameters, i.e., the parameters
c defining the search ellipse (data search neighborhood) are described in 
c section 2.3 of the GSLIB User's guide.
c
c
c INPUT VARIABLES:
c
c  nx,ny,nz        	Number of blocks in X,Y, and Z
c  xsiz,ysiz,zsiz   	Spacing of the grid nodes (block size)
c  MAXCTX,Y,Z          	Maximum dimensions of the data search neighborhood
c  radius       	Maximum search radius
c  rotmat               Rotation matrix accounting for anisotropy
c  imult                Current multiple grid
c
c
c OUTPUT VARIABLES:  
c
c  nlsearch          	Number of nodes in the data search neighborhood
c  i[x,y,z]node    	Relative indices of those nodes
c
c
c EXTERNAL REFERENCES:
c
c  sortem          	Sorts multiple arrays in ascending order
c
c
c
c-----------------------------------------------------------------------

      ! Declare dummy arguments
      INTEGER, INTENT(IN) :: imult
      
      ! Declare local variables
      INTEGER :: i,j,k,ic,jc,kc,il,n
      REAL :: xx,yy,zz,hsqd,radsqd,cont
      INTEGER :: nctx, ncty, nctz, nctxy, nctxyz
      REAL, DIMENSION(MAXCTXYZ) :: tmp
      INTEGER, DIMENSION(MAXCTXYZ) :: ordercd,c,d,e,f,g,h

!
! Set up rotation matrix to compute anisotropic distances
! for conditioning data search
!
      CALL SetRotMat(imult)
      radsqd=radius(imult)*radius(imult)
!
! Size of the data search neighborhood
!
      nctx=min(((MAXCTX-1)/2),(nx-1))
      ncty=min(((MAXCTY-1)/2),(ny-1))
      nctz=min(((MAXCTZ-1)/2),(nz-1))
!
! Debugging output:
!
      WRITE(ldbg,*) 'Search for conditioning data'
      WRITE(ldbg,*) 'The maximum range in each coordinate direction is:'
      WRITE(ldbg,*) '          X direction: ',nctx*xsiz
      WRITE(ldbg,*) '          Y direction: ',ncty*ysiz
      WRITE(ldbg,*) '          Z direction: ',nctz*zsiz
      WRITE(ldbg,*) 'Conditioning data are not searched ', 
     +              'beyond this distance!'

!
! Now, set up the table of distances to the unknown, and keep track of 
! the node offsets that are within the search radius:
!
      nlsearch = 0
      DO i=-nctx,nctx
         xx = i * xsiz
         ic = nctx + 1 + i
         DO j=-ncty,ncty
            yy = j * ysiz
            jc = ncty + 1 + j
            DO k=-nctz,nctz
               zz = k * zsiz
               kc = nctz + 1 + k
! Calculate the anisotropic distance:
      	       hsqd = 0.0
               DO n=1,3
                  cont=rotmat(n,1)*xx+rotmat(n,2)*yy+rotmat(n,3)*zz
                  hsqd = hsqd + cont*cont
      	       END DO
               IF(hsqd.le.radsqd) THEN
               nlsearch=nlsearch+1
!
! We want to search by closest distance (anisotropic distance 
! defined by the search ellipse):
!
               tmp(nlsearch)=hsqd
               ordercd(nlsearch)=real((kc-1)*MAXCTXY+(jc-1)*MAXCTX+ic)
               ENDIF
            END DO
         END DO
      END DO
!
! Finished setting up the table of distances to the unknown, 
! now order the nodes such that the closest ones are searched
! first. 
!
      call sortem(1,nlsearch,tmp,1,ordercd,c,d,e,f,g,h)
      DO il=1,nlsearch
         iznode(il)=int((ordercd(il)-1)/MAXCTXY) + 1
         iynode(il)=int((ordercd(il)-(iznode(il)-1)
     +                 *MAXCTXY-1)/MAXCTX)+1
         ixnode(il)=ordercd(il)-(iznode(il)-1)*MAXCTXY
     +                       -(iynode(il)-1)*MAXCTX
         ixnode(il)=ixnode(il)-nctx-1
         iynode(il)=iynode(il)-ncty-1
         iznode(il)=iznode(il)-nctz-1
      END DO
!
! Debugging output if requested:
!
      IF(idbg>1) THEN
         WRITE(ldbg,*) 'There are ',nlsearch,' nearby nodes that will '
         WRITE(ldbg,*) ' be checked until enough conditioning data '
         WRITE(ldbg,*) ' are found.'
         WRITE(ldbg,*)
         DO i=1,nlsearch
            xx = ixnode(i) * xsiz
            yy = iynode(i) * ysiz
            zz = iznode(i) * zsiz
            write(ldbg,100) i,xx,yy,zz
         END DO
 100     format('Point ',i5,' at ',3f12.4)
      ENDIF


      END SUBROUTINE InitializeSearch

c-----------------------------------------------------------------------

      SUBROUTINE SetRotMat(imult)
c-----------------------------------------------------------------------
c
c              Sets up an Anisotropic Rotation Matrix
c              **************************************
c
c Sets up the matrix to transform cartesian coordinates to coordinates
c accounting for angles and anisotropy (see section 2.3 of the 
c GSLIB User's guide for a detailed definition):
c
c
c INPUT PARAMETERS:
c
c   sang1            	 Azimuth angle for principal direction
c   sang2            	 Dip angle for principal direction
c   sang3            	 Third rotation angle
c   sanis1           	 First anisotropy ratio
c   sanis2           	 Second anisotropy ratio
c   rotmat          	 Rotation matrix
c   imult                Current multiple grid
c
c
c OUTPUT PARAMETER:
c
c   rotmat               Rotation matrix accounting for anisotropy
c
c
c-----------------------------------------------------------------------

      ! Declare dummy arguments
      INTEGER, INTENT(IN) :: imult
      
      ! Declare local variables
      REAL :: afac1,afac2,sina,sinb,sint,cosa,cosb,cost
      REAL :: alpha,beta,theta
!
! Converts the input angles to three angles which make more
! mathematical sense:
!
!         alpha   angle between the major axis of anisotropy and the
!                 E-W axis. Note: Counter clockwise is positive.
!         beta    angle between major axis and the horizontal plane.
!                 (The dip of the ellipsoid measured positive down)
!         theta   Angle of rotation of minor axis about the major axis
!                 of the ellipsoid.
!
      IF(sang1(imult)>=0.0.and.sang1(imult)<270.0) then
         alpha=(90.0-sang1(imult))*DEG2RAD
      ELSE
         alpha=(450.0-sang1(imult))*DEG2RAD
      ENDIF
      beta=-1.0*sang2(imult)*DEG2RAD
      theta=sang3(imult)*DEG2RAD
!
! Get the required sines and cosines:
!
      sina  = sin(alpha)
      sinb  = sin(beta)
      sint  = sin(theta)
      cosa  = cos(alpha)
      cosb  = cos(beta)
      cost  = cos(theta)
!
! Construct the rotation matrix in the required memory:
!
      afac1 = 1.0 / max(sanis1(imult),EPSILON)
      afac2 = 1.0 / max(sanis2(imult),EPSILON)
      rotmat(1,1) = cosb * cosa
      rotmat(1,2) = cosb * sina
      rotmat(1,3) = -sinb
      rotmat(2,1) = afac1*(-cost*sina + sint*sinb*cosa)
      rotmat(2,2) = afac1*(cost*cosa + sint*sinb*sina)
      rotmat(2,3) = afac1*( sint * cosb)
      rotmat(3,1) = afac2*(sint*sina + cost*sinb*cosa)
      rotmat(3,2) = afac2*(-sint*cosa + cost*sinb*sina)
      rotmat(3,3) = afac2*(cost * cosb)

      END SUBROUTINE SetRotMat
      
c-----------------------------------------------------------------------


      SUBROUTINE RelocateData ()
      IMPLICIT NONE
c-----------------------------------------------------------------------
c
c       Relocate sample data to the closest simulation grid nodes
c       *********************************************************
c
c
c INPUT VARIABLES:
c
c  nd               	Number of data
c  x,y,z(nd)        	Coordinates of the data
c  vr(nd)           	Data values
c  nx,ny,nz        	Number of blocks in X,Y, and Z
c  xmn,ymn,zmn      	Coordinate at the center of the first Block
c  xsiz,ysiz,zsiz   	Spacing of the grid nodes (block size)
c
c
c OUTPUT VARIABLES:  
c
c  simim          	Realization so far
c  nodcut          	Number of nodes simulated in each category so far
c
c
c EXTERNAL REFERENCES:
c
c  getindx          	Gets the (x, y, or z) coordinate of the closest grid node
c
c 
c
c-----------------------------------------------------------------------

      ! Declare local variables
      INTEGER :: ix, iy, iz, id, id2
      REAL :: xx, yy, zz, test, test2
      LOGICAL :: testind

!
! Loop over all sample data:     
!
      DO id=1,nd
!
! Calculate the coordinates of the closest simulation grid node:
!
         CALL getindx(nx,xmn,xsiz,x(id),ix,testind)
         CALL getindx(ny,ymn,ysiz,y(id),iy,testind)
         CALL getindx(nz,zmn,zsiz,z(id),iz,testind)
         xx=xmn+real(ix-1)*xsiz
         yy=ymn+real(iy-1)*ysiz
         zz=zmn+real(iz-1)*zsiz
         test=abs(xx-x(id))+abs(yy-y(id))+abs(zz-z(id))
!
! Assign this data to the node (unless there is a closer data):
!
         IF(simim(ix,iy,iz)>0) THEN
            id2 = simim(ix,iy,iz)
            test2 = abs(xx-x(id2))+abs(yy-y(id2))+abs(zz-z(id2))
            IF(test<test2) simim(ix,iy,iz)=id
            IF(idbg>1) WRITE(ldbg,102) id,id2
         ELSE
            simim(ix,iy,iz)=id
         END IF
      END DO
      
 102  format('Warning data values ',2i5,' are both assigned to '
     +    ,/,'        the same node - taking the closest')
     
!
! Now, enter data values into the simulation grid:
!
      nodcut(1:ncut)=0
      vertnodcut(1:nz,1:ncut)=0
      DO iz=1,nz
         DO iy=1,ny
            DO ix=1,nx
               id=simim(ix,iy,iz)
               IF(id>0) THEN
                  simim(ix,iy,iz) = vr(id) 
                  nodcut(simim(ix,iy,iz))=nodcut(simim(ix,iy,iz))+1
                  IF(ivertprop==1) 
     + vertnodcut(iz,simim(ix,iy,iz))=vertnodcut(iz,simim(ix,iy,iz))+1
               END IF
            END DO
         END DO
      END DO
      END SUBROUTINE RelocateData	

c-------------------------------------------------------------------
      SUBROUTINE RandomPath()
      IMPLICIT NONE
      
c----------------------------------------------------------------------------
c
c                    Work out a random path
c                    **********************
c
c This subroutine works out a random path that visits all nodes of
c the current multiple grid when this grid is simulated without a
c search tree.
c
c
c INPUT VARIABLES:
c
c  nxyzcoarse  	    Number of nodes in the current multiple grid 
c
c
c OUTPUT VARIABLES:
c
c  order           Indices of the nodes to be successively visited
c
c
c____________________________________________________________________________


      ! Declare local variables
      REAL , DIMENSION  (MAXXYZ) :: sim
      INTEGER , DIMENSION  (MAXXYZ) :: c,d,e,f,g,h
      INTEGER :: in
      
      CALL Random_Number(sim(:nxyzcoarse))
        
      DO in=1, nxyzcoarse
         order(in)=in
      END DO
      
      CALL sortem(1,nxyzcoarse,sim,1,order,c,d,e,f,g,h)


      END SUBROUTINE RandomPath


c -------------------------------------------------------------------


      SUBROUTINE SearchClosestNodes(ix,iy,iz)
      USE parameter
      IMPLICIT NONE
c-----------------------------------------------------------------------
c
c               Search for nearby simulated grid nodes
c               **************************************
c
c This subroutine is called only when the current multiple grid is
c simulated without a search tree.
c The idea is to spiral away from the node being simulated and note all
c the nearby nodes that have been simulated.
c
c
c PROGRAM NOTES: Since the original data are assigned to the closest 
c grid nodes, original data and previously simulated grid nodes are
c searched at the same time for local conditioning. 
c Their closeness is measured according to the anisotropic
c distance corresponding to the search ellipse.
c
c
c INPUT VARIABLES:
c
c   ix,iy,iz        	Index of the point currently being simulated
c   simim           	Realization so far
c   nodmax         	Maximum number of nodes that we want
c   noct            	Maximum number of nodes per octant (0=not used)
c   nlsearch          	Number of nodes in the data search neighborhood
c   i[x,y,z]node    	Relative indices of those nodes.
c
c
c
c OUTPUT VARIABLES:
c
c   ncnode          	Number of close nodes
c   cnode[x,y,z]()  	Location of the nodes
c   cnodev()        	Values at the nodes
c
c
c
c-----------------------------------------------------------------------

      ! Declare dummy arguments
      INTEGER, INTENT(IN) :: ix, iy,iz

      ! Declare local variables
      INTEGER :: il,i,j,k,idx,idy,idz,iq
      INTEGER, DIMENSION(8) :: ninoct   
      
! ninoct: the current number of close nodes per octant

      iq=1
      ncnode=0
      ninoct(1:8)=0

! Consider all the nearby nodes until enough have been found:
!      	
      DO il=2, nlsearch
      	 IF(ncnode==nodmax) EXIT
         i=ix+ixnode(il)
         j=iy+iynode(il)
         k=iz+iznode(il)
         IF(i>=1.and.i<=nx.and.j>=1.and.j<=ny.and.k>=1.and.k<=nz) 
     +      THEN
            IF(simim(i,j,k)>UNEST) THEN
!
! Check the number of data already taken from this octant:
!
               IF(noct>0) THEN
                  idx=ix-i
                  idy=iy-j
                  idz=iz-k
                  IF(idz>0) THEN
                     iq = 4
                     IF(idx<=0.and.idy>0) iq=1
                     IF(idx>0.and.idy>=0) iq=2
                     IF(idx<0.and.idy<=0) iq=3
                  ELSE
                     iq=8
                     IF(idx<=0.and.idy>0) iq=5
                     IF(idx>0.and.idy>=0) iq=6
                     IF(idx<0.and.idy<=0) iq=7
                  ENDIF
                  ninoct(iq)=ninoct(iq)+1
               END IF
               
!
! Consider all the nearby nodes until enough have been found:
!      	
               IF(noct==0.or.(noct>0.and.ninoct(iq)<=noct)) THEN
                  ncnode = ncnode + 1
                  cnodex(ncnode) = ixnode(il)
                  cnodey(ncnode) = iynode(il)
                  cnodez(ncnode) = iznode(il)
                  cnodev(ncnode) = simim(i,j,k)
               ENDIF
            END IF
         END IF
      END DO
      				      	
      END SUBROUTINE SearchClosestNodes	

c -------------------------------------------------------------------

      SUBROUTINE InferCpdf(ix,iy,iz,cpdf,imult)
      IMPLICIT NONE
c-----------------------------------------------------------------------
c
c         Infer local cpdf from training image
c         ************************************
c
c This subroutine, which is called only when the current multiple
c grid is simulated without a search tree, scans the training image 
c looking for data events identical to the conditioning 
c data event (same data values and same geometric configuration) 
c to infer the cpdf at location (ix,iy,iz).
c
c
c INPUT VARIABLES:
c
c  ix,iy,iz        	Index of the point currently being simulated
c  ncnode          	Number of close nodes
c  cnode[x,y,z]()  	Location of the nodes
c  cnodev()        	Values at the nodes
c  simim           	Realization so far
c  trainim          	Training image
c  nxtr,nytr,nztr       Dimensions of the training image
c  imult                Current simulation grid
c
c
c
c OUTPUT VARIABLES:
c
c  numcd(ix,iy,iz)   	Number of conditioning data finally retained
c
c
c
c-----------------------------------------------------------------------

      ! Declare dummy arguments
      INTEGER, INTENT(IN) :: ix, iy, iz, imult
      REAL, DIMENSION (MAXCUT), INTENT(OUT) :: cpdf
      
      ! Declare local variables
      INTEGER :: icd, ixtr, iytr, iztr, i, j, k
      INTEGER :: icut, sumrepl
      INTEGER, DIMENSION (MAXCUT,MAXNOD) :: replicate
      
! replicate: stores the number of training replicates for all possible
! numbers of conditioning data (1,...,ncnode) and all possible
! central values (1,...,ncut).
      replicate(1:ncut,1:MAXNOD)=0

      IF(idbg>1) WRITE(ldbg,201) ix,iy,iz
201   format(/,' Simulate node:', i5, i5, i5)
      IF(idbg>1) WRITE(ldbg,202) ncnode
202   format(i3, ' conditioning data')
      
      DO icd=1, ncnode
         IF(idbg>2) WRITE(ldbg,203) icd,cnodex(icd),cnodey(icd),
     +                               cnodez(icd),thres(cnodev(icd))
203   format('CD ', i3, ':',i5,i5,i5, ', category=', i3)
      END DO
      	            	      
!     
! Loop over all the nodes of the training image:
!     
      DO ixtr=1, nxtr(imult)
        DO iytr=1, nytr(imult)
          DO iztr=1, nztr(imult)

! Loop over all the nodes of the data template consisting of both 
! conditioning soft and hard data, centered on (ixtr,iytr,iztr)
      	    DO icd=1, ncnode
              i=ixtr+cnodex(icd)
              j=iytr+cnodey(icd)
              k=iztr+cnodez(icd)

! Check if the current node is within the training image; if not,
! go to the next training image node
           IF(i>=1.and.i<=nxtr(imult).and.j>=1.and.j<=nytr(imult).
     +          and.k>=1.and.k<=nztr(imult)) THEN
     
! Check if the value at the current node is the same as the
! conditioning data value; if not, go to the next training image node
              IF(trainim(i,j,k,imult)==cnodev(icd)) THEN
      	        replicate(trainim(ixtr,iytr,iztr,imult),icd)=
     +          replicate(trainim(ixtr,iytr,iztr,imult),icd)+1
      	      ELSE 
      		EXIT	
              END IF
            ELSE 
      	      EXIT
      	    END IF
      	    END DO
      	  END DO
      	END DO
      END DO
!
! Now, compute the cpdf:
!
      IF(ivertprop==1) THEN
         cpdf(1:ncut)=vertpdf(iz,1:ncut)
      ELSE
         cpdf(1:ncut)=pdf(1:ncut)
      END IF
      
      DO icd=ncnode, 1, -1
          sumrepl=SUM(replicate(1:ncut,icd))
          IF(idbg>2) WRITE(ldbg,*) 'Training replicates:', sumrepl

! Check if enough training replicates: if yes, calculate the cpdf,
! otherwise drop the furthest away datum
          IF(sumrepl>=cmin) THEN
             cpdf(1:ncut)=real(replicate(1:ncut,icd))/real(sumrepl)
             numcd(ix,iy,iz)=icd
             EXIT
          END IF
          IF(idbg>2) WRITE(ldbg,204) 
204       format('Not enough replicates, drop the furthest away CD.')
          IF(idbg>2) WRITE(ldbg,205) icd-1
205       format('Infer cpdf for', i3, ' CD.')
      END DO
      
! Write the local cpdf inferred if debugging required:
      IF(idbg>1) THEN
         WRITE(ldbg,206) numcd(ix,iy,iz)
206      format('Number of CD finally retained: ', i3)          
         DO icut=1,ncut
            WRITE(ldbg,207) thres(icut), cpdf(icut)
207         format('Cpdf for category ', i3, ' : ', f6.4)
         END DO
      END IF
      
      
      END SUBROUTINE InferCpdf
      
c-----------------------------------------------------------------------


      SUBROUTINE Simulation (imult)
      IMPLICIT NONE
c-----------------------------------------------------------------------
c
c           Conditional simulation of a 3-D rectangular grid
c           ************************************************
c
c This subroutine simulates the current (3-D rectangular) multiple grid.
c The conditional simulation is achieved by sequential simulation of all
c the nodes visited by a random path. No search tree is used here!
c
c
c INPUT VARIABLES:
c
c  ncoarse		Current multiple grid number
c  n[x,y,z]coarse	Dimensions of the current multiple grid
c  nxyzcoarse  	    	Number of nodes in the current multiple grid 
c  simim           	Realization so far
c  imult                Current simulation grid
c
c
c
c OUTPUT VARIABLE: All the nodes of the current multiple grid are simulated
c
c
c
c-----------------------------------------------------------------------

      
      ! Declare dummy arguments
      INTEGER, INTENT(IN) :: imult

      ! Declare local variables
      INTEGER :: in, ic, ix, iy, iz, irepo
      REAL, DIMENSION  (MAXCUT) :: ccdf, cpdf
      INTEGER :: jx, jy, jz
      
      irepo=max(1,min((nxyzcoarse/10),10000))
!
! Main loop over all simulation grid nodes:
!      
      DO in=1, nxyzcoarse
      	 IF(mod(in,irepo)==0) WRITE(*,103) in
 103     format('   currently on node ',i9)
!
! Figure out the location of this point and make sure it has
! not been assigned a value already:
!
         jz=1+int((order(in)-1)/nxycoarse)
         jy=1+int((order(in)-(jz-1)*nxycoarse-1)/nxcoarse)
         jx=order(in)-(jz-1)*nxycoarse-(jy-1)*nxcoarse
         ix=(jx-1)*ncoarse+1
         iy=(jy-1)*ncoarse+1
         iz=(jz-1)*ncoarse+1
     	 IF(simim(ix, iy, iz)<0) THEN
!
! Now, we'll simulate the point ix,iy,iz:
!      

! First, get close conditioning data:
      	    CALL SearchClosestNodes(ix,iy,iz)
      	 
! If no conditioning data were found, use the marginal pdf as
! local cpdf, otherwise infer the local cpdf from the training image:	 
            IF(ncnode==0) THEN
               numcd(ix,iy,iz)=0
               IF(ivertprop==1) THEN
                  cpdf(1:ncut)=vertpdf(iz,1:ncut)
               ELSE
                  cpdf(1:ncut)=pdf(1:ncut)
               END IF
            ELSE
              CALL InferCpdf(ix,iy,iz,cpdf,imult)
            END IF
                              
! Draw a random number and assign a value to this node:                                    
            CALL DrawValue(ix, iy, iz, cpdf, imult)
         END IF
      END DO
      
      END SUBROUTINE Simulation	


c-------------------------------------------------------------------
      SUBROUTINE DrawValue (ix, iy, iz, cpdf, imult)
      IMPLICIT NONE
      
c----------------------------------------------------------------------------
c
c                    Draw a value from a cpdf
c                    ************************
c
c  This subroutine draws a simulated value from the local cpdf at (ix,iy,iz).
c
c
c INPUT VARIABLES:
c
c  ix,iy,iz        	Index of the point currently being simulated
c  cpdf         	Local cpdf
c  idbg     	        Integer debugging level (0=none,2=normal,4=serious)
c  ldbg      	        Unit number for the debugging output
c  imult                Current simulation grid
c
c
c
c OUTPUT VARIABLES:
c
c  simim          	Realization so far
c  nodcut          	Number of nodes simulated in each category so far
c
c
c____________________________________________________________________________

      ! Declare dummy arguments
      REAL, DIMENSION  (MAXCUT) :: cpdf
      INTEGER, INTENT(IN) :: ix,iy,iz,imult

      ! Declare local variables
      INTEGER :: ic
      REAL, DIMENSION  (MAXCUT) :: ccdf
      REAL :: p, total, totalnodcut

!
! Apply the servosystem correction:
!
      IF(ivertprop==1) THEN
         totalnodcut=real(MAX(sum(vertnodcut(iz,1:ncut)),1))
      ELSE
         totalnodcut=real(MAX(sum(nodcut(1:ncut)),1))
      END IF
      DO ic=1, ncut
         IF(cpdf(ic)>0.05.AND.cpdf(ic)<0.95) THEN
            IF(ivertprop==1) THEN
               cpdf(ic)=cpdf(ic)+servocor(imult)*
     +         (vertpdf(iz,ic)-real(vertnodcut(iz,ic))/totalnodcut)
            ELSE
               cpdf(ic)=cpdf(ic)+
     +         servocor(imult)*(pdf(ic)-real(nodcut(ic))/totalnodcut)
            END IF   
            IF(cpdf(ic)<0.0) cpdf(ic)=0.0
            IF(cpdf(ic)>1.0) cpdf(ic)=1.0
         END IF
      END DO
      
      total=sum(cpdf(1:ncut))
      cpdf(1:ncut)=cpdf(1:ncut)/total
      IF(idbg>1.AND.iservo==1) THEN
         WRITE(ldbg,210) 
210      format('After servosystem correction:')
         DO ic=1,ncut
            WRITE(ldbg,211) thres(ic), cpdf(ic)
211         format('Cpdf for category ', i3, ' : ', f6.4)
         END DO
      END IF
                      
      ccdf(1)=cpdf(1)
      DO ic=2, ncut
     	 ccdf(ic)=ccdf(ic-1)+cpdf(ic)
      END DO
     	  
      total=sum(cpdf(1:ncut))
     	  
     	  
! Draw a random value from the local ccdf

      CALL Random_Number(p)
      simim(ix, iy, iz)=1
      DO ic=2, ncut
         IF (p>ccdf(ic-1)) simim(ix,iy,iz)=ic
      END DO
      	  
      nodcut(simim(ix,iy,iz))=nodcut(simim(ix,iy,iz))+1
      IF(ivertprop==1) 
     + vertnodcut(iz,simim(ix,iy,iz))=vertnodcut(iz,simim(ix,iy,iz))+1
     
      IF(idbg>1) WRITE(ldbg,212) ix,iy,iz, thres(simim(ix,iy,iz))
212   format('Category simulated at ', i5, i5, i5, ': ', i3)
      
      END SUBROUTINE DrawValue	

c----------------------------------------------------------------------
      
      SUBROUTINE SortTemplate (imult)
      IMPLICIT NONE
c-----------------------------------------------------------------------
c
c                      Sort template data locations
c                      ****************************
c
c This subroutine sorts the locations of the data template 
c (used to construct the search trees) according to the
c anisotropic distance corresponding to the search ellipse. Thus the
c conditioning data are searched later in order of closeness according 
c to that distance.
c
c
c INPUT VARIABLES:
c
c  nltemplate           Number of template data locations
c  i[x,y,z]template     Coordinates of template data locations
c  rotmat   		Rotation matrix accounting for anisotropy
c  imult                Current simulation grid
c
c
c EXTERNAL REFERENCES:
c
c  sortem          	Sorts multiple arrays in ascending order
c
c
c
c-----------------------------------------------------------------------

      ! Declare dummy arguments
      INTEGER, INTENT(IN) :: imult

      ! Declare local variables
      INTEGER :: ind,n
      REAL :: xx,yy,zz,hsqd,cont
      REAL, DIMENSION(MAXNOD) :: tmp
      INTEGER, DIMENSION(MAXNOD) :: e,f,g,h

      CALL SetRotMat(imult)
      
      DO ind=1,nltemplate
         xx=ixtemplate(ind)
         yy=iytemplate(ind)
         zz=iztemplate(ind)
! Calculate the anisotropic distance:
      	 hsqd = 0.0
         DO n=1,3
            cont=rotmat(n,1)*xx+rotmat(n,2)*yy+rotmat(n,3)*zz
            hsqd = hsqd + cont*cont
      	 END DO
         tmp(ind) = hsqd
      END DO
!
! Finished setting up the table of distances to the unknown, 
! now order the nodes such that the closest ones are searched
! first. 
!
      call sortem(1,nltemplate,tmp,3,ixtemplate,iytemplate,
     +            iztemplate,e,f,g,h)
       
      END SUBROUTINE SortTemplate

c----------------------------------------------------------------------
      
      SUBROUTINE RandomPathTree()
      IMPLICIT NONE
      
c----------------------------------------------------------------------------
c
c                    Work out a random path
c                    **********************
c
c This subroutine works out a pseudo-random path that visits first 
c the best informed nodes of the current multiple grid when this grid
c is simulated with a search tree is used.
c
c
c INPUT VARIABLES:
c
c  nxyzcoarse  	    Number of nodes in the current multiple grid 
c
c
c OUTPUT VARIABLES:
c
c  order           Indices of the nodes to be successively visited
c
c
c____________________________________________________________________________


      ! Declare local variables
      REAL , DIMENSION  (MAXXYZ) :: sim
      INTEGER , DIMENSION  (MAXXYZ) :: c,d,e,f,g,h
      INTEGER :: in, ind, ix,iy,iz,jx,jy,jz,i,j,k
      
      CALL Random_Number(sim(:nxyzcoarse))
      DO in=1, nxyzcoarse
         jz=1+int((in-1)/nxycoarse)
         jy=1+int((in-(jz-1)*nxycoarse-1)/nxcoarse)
         jx=in-(jz-1)*nxycoarse-(jy-1)*nxcoarse
         ix=(jx-1)*ncoarse+1
         iy=(jy-1)*ncoarse+1
         iz=(jz-1)*ncoarse+1
!
! Figure out the number of CD at this location
!
         ncnode=0

! Consider all the nearby nodes until enough have been found:

         DO ind=1,nltemplate
            IF(ncnode==nodmax) EXIT
            i=ix+ixnode(ind)
            j=iy+iynode(ind)
            k=iz+iznode(ind)
            IF(i>=1.and.i<=nx.and.j>=1.and.j<=ny.and.
     +         k>=1.and.k<=nz) THEN
               IF(simim(i,j,k)>UNEST) ncnode=ncnode+1
            END IF
         END DO
         order(in)=in
         sim(in)=sim(in)-ncnode
      END DO
      
      CALL sortem(1,nxyzcoarse,sim,1,order,c,d,e,f,g,h)


      END SUBROUTINE RandomPathTree


c--------------------------------------------------------------------
      SUBROUTINE InferTree(stree,imult)
      IMPLICIT NONE

c----------------------------------------------------------------------------
c
c                  Construct the search tree
c                  *************************
c
c This subroutine constructs the search tree 'stree' corresponding to
c the current multiple grid. 
c The training image is scanned one single time.
c At each training node (ix,iy,iz), all locations of the data template
c centred on (ix,iy,iz) are recursively visited using the recursive subroutine 
c UpdateTree, and the search tree is updated accordingly.
c
c
c INPUT VARIABLES:
c
c  trainim     		Training image
c  nxtr,nytr,nztr	Dimensions of the training image
c  imult                Current simulation grid
c
c
c OUTPUT VARIABLES:
c
c  stree     	Search tree containing the training cpdf's
c
c
c
c____________________________________________________________________________


      ! Declare dummy arguments
      TYPE(streenode) :: stree
      INTEGER, INTENT(IN) :: imult

      ! Declare local variables
      INTEGER :: ix, iy, iz, ccut

!
! Loop over all the nodes of the training image:
!
      DO iz=1,nztr(imult)
         DO iy=1,nytr(imult)
            DO ix=1,nxtr(imult)
         
! ccut: current central value:
               ccut=trainim(ix,iy,iz,imult)
               CALL UpdateTree(stree,imult,ix,iy,iz,ccut,1)
            END DO
         END DO
      END DO
      
      END SUBROUTINE InferTree

 ! -------------------------------------------------------------------
      RECURSIVE SUBROUTINE UpdateTree(stree,imult,ix,iy,iz,ccut,icd)
      IMPLICIT NONE

c----------------------------------------------------------------------------
c
c                  Update the search tree
c                  **********************
c
c This recursive subroutine updates the search tree 'stree' for the cpdfs
c scanned at the training location (ix,iy,iz) when visiting recursively 
c all locations of the data template centered on (ix,iy,iz). 
c
c
c INPUT VARIABLES:
c
c  trainim     		Training image
c  nxtr,nytr,nztr	Dimensions of the training image
c  ix,iy,iz     	Index of the training image node currently visited
c  ccut			Training data value at this node
c  i[x,y,z]node         Relative indices of the nodes in the 
c                       data search neighborhood
c  ncoarse		Current multiple grid number
c  icd			Index of the current data template location
c  imult                Current simulation grid
c  
c
c
c OUTPUT VARIABLES: Search tree stree updated
c
c
c____________________________________________________________________________


      ! Declare dummy arguments
      TYPE(streenode) :: stree
      INTEGER, INTENT(IN) :: imult,ix,iy,iz,ccut,icd

      ! Declare local variables
      INTEGER :: icut,ixh,iyh,izh
     
! First, calculate the coordinates of the location
! currently visited in the data template:

      ixh=ix+ixnode(icd)
      iyh=iy+iynode(icd)
      izh=iz+iznode(icd)
      
! Check if the current template location is within the training image:
      
      IF(ixh>=1.AND.ixh<=nxtr(imult).AND.iyh>=1.AND.
     +   iyh<=nytr(imult).AND.izh>=1.AND.izh<=nztr(imult)) THEN
         icut=trainim(ixh,iyh,izh,imult)
         
! If the search tree node corresponding to the current conditioning
! configuration does not exit, create it: 
         
         IF(.NOT.ASSOCIATED(stree%next)) CALL ExtendTree(stree,icd)
         
! Update the node corresponding to the current central value: 

         stree%next(icut)%repl(ccut)=
     +   stree%next(icut)%repl(ccut)+1
     
! If locations need still be visited in the data template, visit them
! and update the search tree accordingly:  
  
         IF(icd<nltemplate)
     + CALL UpdateTree(stree%next(icut),imult,ix,iy,iz,
     +                  ccut,icd+1)
      END IF


      END SUBROUTINE UpdateTree
      
      
c-------------------------------------------------------------------
      SUBROUTINE ExtendTree(stree,icd)
      IMPLICIT NONE

c----------------------------------------------------------------------------
c
c                  Extend the search tree
c                  **********************
c
c This subroutine creates a new node extending the search tree 'stree'. 
c
c
c____________________________________________________________________________

      ! Declare dummy arguments
      TYPE(streenode) :: stree
      INTEGER, INTENT (IN) :: icd
      
      ! Declare local variables
      INTEGER :: err, ic
      
! Create a new node:

      ALLOCATE(stree%next(ncut),STAT=err)
      
      IF(err/=0) THEN
         Write(*,*) 'Machine out of memory'
         STOP
      END IF
      
! Initialize the new node:
      
      DO ic=1,ncut
         stree%next(ic)%repl(1:ncut)=0
         NULLIFY(stree%next(ic)%next)
      END DO

      END SUBROUTINE ExtendTree
      
      
c--------------------------------------------------------------------
      RECURSIVE SUBROUTINE DeallocateTree(stree,icd)
      IMPLICIT NONE

c----------------------------------------------------------------------------
c
c                  Deallocate the search tree
c                  *************************
c
c This subroutine deallocates recursively the search tree 'stree',
c starting from the leaves to the root.
c
c
c____________________________________________________________________________


      ! Declare dummy arguments
      TYPE(streenode) :: stree
      INTEGER, INTENT(IN) :: icd

      ! Declare local variables
      INTEGER :: icut
      
      IF(ASSOCIATED(stree%next)) THEN
         DO icut=1,ncut
            CALL DeallocateTree(stree%next(icut),icd+1)
         END DO
         DEALLOCATE(stree%next)
      END IF

      END SUBROUTINE DeallocateTree      


c--------------------------------------------------------------------
      SUBROUTINE AssignData()
      IMPLICIT NONE
      
c----------------------------------------------------------------------------
c
c                  Assign sample data to closest grid nodes
c                  ***************************************
c
c This subroutine assigns the original sample data to the closest nodes
c of the multiple grid to be simulated with a search tree.
c
c
c INPUT VARIABLES:
c
c  ncoarse		Current multiple grid number
c  n[x,y,z]coarse	Dimensions of the current multiple grid
c  nxyzcoarse  	    	Number of nodes in the current multiple grid 
c  nd               	Number of original sample data
c  x,y,z(nd)        	Coordinates of the data
c  vr(nd)           	Data values
c
c
c OUTPUT VARIABLES:  
c
c  simim          	Realization so far
c  nodcut          	Number of nodes simulated in each category so far
c
c
c EXTERNAL REFERENCES:
c
c  getindx          	Gets the (x, y, or z) coordinate of the closest grid node
c
c
c
c____________________________________________________________________________

      ! Declare local variables
      INTEGER :: ix, iy, iz, id, id2
      INTEGER :: jx, jy, jz
      REAL :: xx, yy, zz, test, test2
      REAL :: xmncoarse, ymncoarse, xsizcoarse, ysizcoarse
      REAL :: zmncoarse, zsizcoarse
      LOGICAL :: testind
      INTEGER, DIMENSION (MAXX,MAXY,MAXZ) :: simtemp

!
! Define specifications of the current multiple grid.
!
      xmncoarse=xmn
      ymncoarse=ymn
      zmncoarse=zmn
      xsizcoarse=xsiz*ncoarse
      ysizcoarse=ysiz*ncoarse
      zsizcoarse=zsiz*ncoarse
      simtemp(1:nxcoarse,1:nycoarse,1:nzcoarse)=UNEST

!
! Loop over all the original sample data
!    
      DO id=1,nd
!
! Calculate the coordinates of the closest simulation grid node:
!
        CALL getindx(nxcoarse,xmncoarse,xsizcoarse,x(id),ix,testind)
        CALL getindx(nycoarse,ymncoarse,ysizcoarse,y(id),iy,testind)
        CALL getindx(nzcoarse,zmncoarse,zsizcoarse,z(id),iz,testind)
        xx  = xmncoarse + real(ix-1)*xsizcoarse
        yy  = ymncoarse + real(iy-1)*ysizcoarse
        zz  = zmncoarse + real(iz-1)*zsizcoarse
        test = abs(xx-x(id)) + abs(yy-y(id)) + abs(zz-z(id))
!
! Assign this data to the node (unless there is a closer data):
!
        IF(simtemp(ix,iy,iz)>0) THEN
          id2 = simtemp(ix,iy,iz)
          test2 = abs(xx-x(id2)) + abs(yy-y(id2)) + abs(zz-z(id2))
          IF(test<test2) simtemp(ix,iy,iz)=id
        ELSE
           simtemp(ix,iy,iz)=id
        END IF
      END DO
!
! Now, enter data values into the simulated grid:
!
      DO iz=1,nzcoarse
         DO iy=1,nycoarse
      	    DO ix=1,nxcoarse
               id=simtemp(ix,iy,iz)
               IF(id>0) THEN
                  jz=(iz-1)*ncoarse+1
                  jy=(iy-1)*ncoarse+1
                  jx=(ix-1)*ncoarse+1

! Check if there is already a simulated value; if yes, replace it.
                  IF(simim(jx,jy,jz)>0) THEN
                     nodcut(simim(jx,jy,jz))=nodcut(simim(jx,jy,jz))-1
                     IF(ivertprop==1) 
     + vertnodcut(jz,simim(jx,jy,jz))=vertnodcut(jz,simim(jx,jy,jz))-1
                  END IF
                  simim(jx,jy,jz) = vr(id)  
                  nodcut(simim(jx,jy,jz))=nodcut(simim(jx,jy,jz))+1
                  IF(ivertprop==1) 
     + vertnodcut(jz,simim(jx,jy,jz))=vertnodcut(jz,simim(jx,jy,jz))+1
             
! Indicates with a special value assigned to numcd that a sample data
! has been assigned to the node.
                  numcd(jx,jy,jz)=10*UNEST           
               END IF
	    END DO	
         END DO
      END DO
 
      END SUBROUTINE AssignData



c-------------------------------------------------------------------
      SUBROUTINE UnassignData()
      IMPLICIT NONE
      
c----------------------------------------------------------------------------
c
c                    Unassign sample data
c                    ********************
c
c This subroutine unassigns the original sample data from the current
c multiple grid once all nodes of that grid are simulated.
c
c
c INPUT VARIABLES:
c
c  ncoarse		Current multiple grid number
c
c
c OUTPUT VARIABLES:  
c
c  simim          	Realization so far
c  nodcut          	Number of nodes simulated in each category so far
c
c
c____________________________________________________________________________

      ! Declare local variables
      INTEGER :: ix,iy,iz,jx,jy,jz

! Loop over all the nodes of the current simulation grid:

      DO jz=1, nzcoarse
         iz=(jz-1)*ncoarse+1
         DO jy=1, nycoarse
            iy=(jy-1)*ncoarse+1
            DO jx=1, nxcoarse
               ix=(jx-1)*ncoarse+1
            
! Check if an original sample data has been assigned to the current node.
! If yes, remove it.

               IF(numcd(ix,iy,iz)==UNEST*10) THEN
                nodcut(simim(ix,iy,iz))=nodcut(simim(ix,iy,iz))-1
                IF(ivertprop==1) 
     + vertnodcut(iz,simim(ix,iy,iz))=vertnodcut(iz,simim(ix,iy,iz))-1
                simim(ix,iy,iz)=UNEST
                numcd(ix,iy,iz)=UNEST
            END IF
            END DO
         END DO
      END DO

      END SUBROUTINE UnassignData

c-------------------------------------------------------------------

      SUBROUTINE InferCpdfTree(ix,iy,iz,cpdf,stree)
      IMPLICIT NONE

c----------------------------------------------------------------------------
c
c                    Return local cpdf
c                    *****************
c
c This subroutine returns the local cpdf at (ix,iy,iz).
c
c PROGRAM NOTES: If the cpdf cannot be inferred, the furthest 
c away conditioning soft data then hard data are dropped. 
c
c INPUT VARIABLES:
c
c  ix,iy,iz        	Index of the point currently being simulated
c  ncnode          	Number of close nodes
c  cnode[x,y,z]()  	Location of the nodes
c  cnodev()        	Values at the nodes
c  simim           	Realization so far
c  trainim          	Training image
c  nxtr,nytr,nztr       Dimensions of the training image
c  idbg     	        Integer debugging level (0=none,2=normal,4=serious)
c  ldbg      	        Unit number for the debugging output
c
c
c
c OUTPUT VARIABLES:
c
c  numcd(ix,iy,iz)   	Number of conditioning data finally retained
c
c
c____________________________________________________________________________

      ! Declare dummy arguments
      INTEGER, INTENT(IN) :: ix, iy, iz
      REAL, DIMENSION (MAXCUT), INTENT(OUT) :: cpdf
      TYPE(streenode) :: stree

      
      ! Declare local variables
      INTEGER :: i, j, k, ind, maxind, icut , sumrepl
      INTEGER, DIMENSION (MAXCUT) :: replicate

!
! First, spiral away from the node being simulated and node all 
! the nearby nodes that have been simulated
!
      ncnode=0
      
! maxind: location index of the furthest away conditioning datum      
      maxind=0

! Consider all the nearby nodes until enough have been found:

      DO ind=1,nltemplate
         IF(ncnode==nodmax) EXIT
         i=ix+ixnode(ind)
         j=iy+iynode(ind)
         k=iz+iznode(ind)
          
         cnodev(ind)=UNEST
         IF(i>=1.and.i<=nx.and.j>=1.and.j<=ny.and.
     +      k>=1.and.k<=nz) THEN
            cnodev(ind)=simim(i,j,k)
            IF(cnodev(ind)>UNEST) THEN
               nlcd(ind)=
     +         nlcd(ind)+1
               ncnode=ncnode+1
               maxind=ind
           IF(idbg>2) WRITE(ldbg,1204) ind,ixnode(ind),
     +          iynode(ind),iznode(ind),
     +          thres(cnodev(ind))
1204  format('hard CD ', i3, ':',i5,i5,i5, ', category=', i3)
            END IF
         END IF
      END DO
      

!
! Now, compute the cpdf
!         
! replicate: stores the number of training replicates for all possible
! numbers of conditioning data (1,...,ncnode) and all possible
! central values (1,...,ncut).
      
      IF(idbg>1) WRITE(ldbg,401) ix,iy,iz
401   format(/,' Simulate node:', i5, i5, i5)
      IF(idbg>1) WRITE(ldbg,402) ncnode
402   format(i3, ' hard conditioning data')

! If enough identical data events, compute cpdf, otherwise drop the
! furthest away datum:

      IF(ivertprop==1) THEN
         cpdf(1:ncut)=vertpdf(iz,1:ncut)
      ELSE
         cpdf(1:ncut)=pdf(1:ncut)
      END IF

      DO
         replicate(1:ncut)=0
         CALL RetrieveCpdfTree(1,stree,replicate,maxind)
         sumrepl=SUM(replicate(1:ncut))
         IF(idbg>2) WRITE(ldbg,*) 'Training replicates:', sumrepl
! Check if enough training replicates: if yes, calculate the cpdf,
! otherwise drop the furthest away datum
         IF(sumrepl>=cmin) THEN
            cpdf(1:ncut)=real(replicate(1:ncut))/real(sumrepl)
            EXIT
         ELSE
            ncnode=ncnode-1
            nldropped(maxind)=nldropped(maxind)+1
            IF(idbg>2) WRITE(ldbg,404) 
404       format('Not enough replicates, drop the furthest away CD.')
            IF(idbg>2) WRITE(ldbg,405) ncnode
405       format('Infer cpdf for', i3, ' CD.')
            DO 
               maxind=maxind-1
               IF(maxind==0) EXIT
               IF(cnodev(maxind)/=UNEST) EXIT 
            END DO
         END IF
      END DO
      
      numcd(ix,iy,iz)=ncnode
      
! Write out the cpdf if debugging required:
      IF(idbg>1) THEN
         WRITE(ldbg,406) ncnode
406      format('Number of CD finally retained: ', i3)          
         DO icut=1,ncut
            WRITE(ldbg,407) thres(icut), cpdf(icut)
407         format('Cpdf for category ', i3, ' : ', f6.4)
         END DO
      END IF
      
      END SUBROUTINE InferCpdfTree

c-------------------------------------------------------------------
      RECURSIVE SUBROUTINE RetrieveCpdfTree(cdind,stree,
     +                                        replicate,maxind)
      IMPLICIT NONE
      
c----------------------------------------------------------------------------
c
c                    Compute local cpdf from search tree
c                    ***********************************
c
c This subroutine retrieves the local cpdf at (ix,iy,iz) from the search tree.
c
c
c____________________________________________________________________________

      ! Declare dummy arguments
      INTEGER,INTENT(IN) :: cdind, maxind
      INTEGER, DIMENSION (MAXCUT), INTENT(INOUT) :: replicate
      TYPE(streenode) :: stree

      ! Declare local variables
      INTEGER :: ic
      
! cdind: current level in the search tree.      

      IF(cdind<=maxind) THEN
         ic=cnodev(cdind)
         
         
! If there is a conditioning data at the template location cdind, 
! consider only that conditioning value, otherwise sum up over all
! values possibly taken by the location cdind:
         
         IF(ASSOCIATED(stree%next)) THEN   
            IF(ic>UNEST) THEN 
               CALL RetrieveCpdfTree(cdind+1,
     +            stree%next(ic),replicate,maxind)
            ELSE
              DO ic=1,ncut
                 CALL RetrieveCpdfTree(cdind+1,
     +              stree%next(ic),replicate,maxind)
              END DO
            END IF
         END IF
      ELSE
         replicate(1:ncut)=replicate(1:ncut)+stree%repl(1:ncut)
      END IF

      END SUBROUTINE RetrieveCpdfTree

      
c-------------------------------------------------------------------
      SUBROUTINE SimulationTree (stree,imult)
      IMPLICIT NONE
      
c----------------------------------------------------------------------------
c
c                    Simulate the current multiple grid
c                    **********************************
c
c This subroutine simulates the current (3-D rectangular) multiple grid.
c The conditional simulation is achieved by sequential simulation of all
c the nodes visited by a pseudo-random path. A search tree is used here!
c
c
c INPUT VARIABLES:
c
c  ncoarse		Current multiple grid number
c  n[x,y,z]coarse	Dimensions of the current multiple grid
c  nxyzcoarse  	    	Number of nodes in the current multiple grid 
c  simim           	Realization so far
c  idbg     	        Integer debugging level (0=none,2=normal,4=serious)
c  ldbg      	        Unit number for the debugging output
c  imult                Current simulation grid
c
c
c
c OUTPUT VARIABLE: All the nodes of the current multiple grid are simulated
c
c
c____________________________________________________________________________

      ! Declare dummy arguments
      TYPE(streenode) :: stree
      INTEGER, INTENT(IN) :: imult
      
      ! Declare local variables
      INTEGER :: in, ix, iy, iz, irepo, ncnode, ic
      REAL, DIMENSION  (MAXCUT) :: cpdf
      INTEGER :: jx,jy,jz
        
      irepo=max(1,min((nxyzcoarse/10),10000))
!
! Main loop over all the nodes of the current multiple grid:
!            
      DO in=1, nxyzcoarse
         IF(mod(in,irepo)==0) WRITE(*,303) in
 303     format('   currently on node ',i9)
!
! Figure out the location of this point and make sure it has
! not been assigned a value already:
!
         jz=1+int((order(in)-1)/nxycoarse)
         jy=1+int((order(in)-(jz-1)*nxycoarse-1)/nxcoarse)
         jx=order(in)-(jz-1)*nxycoarse-(jy-1)*nxcoarse
         ix=(jx-1)*ncoarse+1
         iy=(jy-1)*ncoarse+1
         iz=(jz-1)*ncoarse+1

         IF(simim(ix, iy, iz)<0) THEN
            nodsim=nodsim+1

! Infer the local cpdf using the search tree
            CALL InferCpdfTree(ix, iy, iz, cpdf, stree)
! Draw a random number and assign a value to this node:                                    
            CALL DrawValue(ix, iy, iz, cpdf, imult)
         END IF

      END DO
      
      END SUBROUTINE SimulationTree
            
c-------------------------------------------------------------------
      SUBROUTINE MeanNumberCD (meanCD)
      IMPLICIT NONE
      
c----------------------------------------------------------------------------
c
c             Return the mean number of conditioning data retained
c             ****************************************************
c
c
c
c INPUT VARIABLES:
c
c  ncoarse		Current multiple grid number
c  n[x,y,z]coarse	Dimensions of the current multiple grid
c  nxyzcoarse  	    	Number of nodes in the current multiple grid 
c  simim           	Realization so far
c
c
c
c OUTPUT VARIABLE: mean number of conditioning data retained to simulate
c                  the current multiple grid
c
c
c____________________________________________________________________________

      ! Declare dummy arguments
      REAL, INTENT(OUT) :: meanCD
      
      ! Declare local variables
      INTEGER :: totalncd, numncd, ix, iy, iz, jx, jy, jz

      totalncd=0
      numncd=0
      DO jz=1, nzcoarse
         iz=(jz-1)*ncoarse+1
         DO jy=1, nycoarse
            iy=(jy-1)*ncoarse+1
            DO jx=1, nxcoarse
               ix=(jx-1)*ncoarse+1
               IF(numcd(ix,iy,iz)>=0) THEN 
                  totalncd=totalncd+numcd(ix,iy,iz)
                  numncd=numncd+1
               END IF
            END DO
         END DO
      END DO
      
      meanCD=real(totalncd)/real(numncd)
      END SUBROUTINE MeanNumberCD
            
      END MODULE simul

c------------------------------------------------------------
c------------------------------------------------------------


      PROGRAM snesim
      USE parameter
      USE simul
      IMPLICIT NONE

      ! Declare local variables
      INTEGER :: isim, ix, iy, iz, imult, ic, iter, ind
      INTEGER :: totalncd, numncd, jx, jy, jz
      REAL :: meanCD
      TYPE(streenode), TARGET :: searchtree
      REAL, DIMENSION (MAXCUT) :: simpdf
      

! Read the parameters and data:
      CALL ReadParm
      
!
! Main loop over all the simulations:
!
      DO isim=1, nsim

!      
! Initialize the simulation and assign the data to the closest grid nodes:
!
         simim(1:nx,1:ny,1:nz)=UNEST
         numcd(1:nx,1:ny,1:nz)=UNEST
! Assign original sample data to the closest simulation grid nodes
         CALL RelocateData()
         
         WRITE(*,*)
         WRITE(*,*) 'Working on realization number ',isim
         
         IF(idbg>0) THEN
            WRITE(ldbg,2000) isim
2000        format(/,/' Working on realization number:',i4)
         END IF

!
! Simulate the coarsest grids without search tree
!
         DO imult=nmult,1,-1
            ncoarse=2**(imult-1)
            nxcoarse=MAX(1,(nx-1)/ncoarse+1)
            nycoarse=MAX(1,(ny-1)/ncoarse+1)
            nzcoarse=MAX(1,(nz-1)/ncoarse+1)
            nxycoarse=nxcoarse*nycoarse
            nxyzcoarse=nxycoarse*nzcoarse
            
            WRITE(*,*) 'working on grid: ', imult
            IF(idbg>0) THEN
               WRITE(ldbg,2001) imult
2001           format(/' Working on grid:',i4)
            END IF
     
            IF(imult>streemult) THEN

! Set up the spiral search: 
               CALL InitializeSearch(imult)
            
! Work out a random path for this realization:
               CALL RandomPath()

! Perform simulation:
               CALL Simulation(imult)
           
            ELSE
         
!
! Simulate the finest grids using search trees
!

! Sort the data template locations in order of closeness:            
               CALL SortTemplate(imult)
               
! Rescale data template used to construct the seach tree
	       ixnode(1:nltemplate)=ncoarse*ixtemplate(1:nltemplate)
	       iynode(1:nltemplate)=ncoarse*iytemplate(1:nltemplate)
	       iznode(1:nltemplate)=ncoarse*iztemplate(1:nltemplate)
	       nlcd(1:nltemplate)=0
	       nldropped(1:nltemplate)=0
	       nodsim=0
            
! Builds the search tree corresponding to the current multiple grid:         
               searchtree%repl(1:ncut)=int(pdf(1:ncut)*nxyz)
               CALL InferTree(searchtree,imult)
         
! Assign data to the current multiple grid simulation:
               CALL AssignData()

! Work out a random path for this realization:
               CALL RandomPathTree()
! Perform simulation:
               CALL SimulationTree(searchtree,imult)

! Unassign the data:
               IF(imult>1) CALL UnassignData()
               IF(idbg>0) THEN
                 WRITE(ldbg,*)
                 WRITE(ldbg,*) 'Some statistics on the data template' 
                 DO ind=1,nltemplate
                   WRITE(ldbg,*)
                   WRITE(ldbg,505) ixnode(ind),iynode(ind),iznode(ind)
505                format('At location ',i4,i4,i4, ':')
                   WRITE(ldbg,506) 100.0*real(nlcd(ind))/real(nodsim)
506                format('a conditioning datum was present',f5.1,
     +                    '% of the time')
	           IF(nlcd(ind)>0) WRITE(ldbg,507) 100.0*
     +                real(nldropped(ind))/real(nlcd(ind))
507                format('this conditioning datum was dropped',f5.1,
     +                    '% of the time')   
	           WRITE(ldbg,508) 100.0*
     +                   real(nlcd(ind)-nldropped(ind))/real(nodsim)
508                format('so this location was actually used',f5.1,
     +                    '% of the time')      
                 END DO
               END IF
               
! Deallocates the search tree:         
               CALL DeallocateTree(searchtree,1)
            ENDIF
            
! Calculate the mean number of CD finally retained in average 
! for the current grid:
            IF(idbg>0) THEN
	       CALL MeanNumberCD(meanCD)
               WRITE(ldbg,173) meanCD
173   format(/,' Mean number of conditioning data retained: ',f6.1)
           END IF
        END DO


! Write out the realization in the output file:
	 totalncd=0
	 numncd=0
         DO iz=1, nz
            DO iy=1, ny
               DO ix=1, nx
                  WRITE(lout, '(2i6)') thres(simim(ix,iy,iz)), 
     +                                numcd(ix,iy,iz)
                  IF(numcd(ix,iy,iz)>=0) THEN 
                     totalncd=totalncd+numcd(ix,iy,iz)
                     numncd=numncd+1
                  END IF
               END DO
            END DO
         END DO
!
! Calculate simulated global proportion for each category:
!
         simpdf(1:ncut)=real(nodcut(1:ncut))/real(nxyz)
         DO ic=1,ncut
            WRITE(*,112) ic, simpdf(ic)
112         format(/,' Simulated proportion of category ',
     +                      i4,' : ',f6.4) 
         END DO
!
! Calculate the mean number of CD retained:
!
         WRITE(*,113) real(totalncd)/real(numncd)
113      format(/,' Mean number of conditioning data retained: ',f6.1)
      END DO
      CLOSE(lout)
      
! Finished:
      WRITE(*,9998) VERSION
 9998 format(/' SNESIM Version: ',f5.3,' Finished'/)
  
      END PROGRAM snesim
