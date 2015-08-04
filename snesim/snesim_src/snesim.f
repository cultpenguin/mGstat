
c@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
c Ch1~Ch4/To incorporate local proportions with servosystem correction
c                                                        /07-23-02/Sunder
c Ch5/To incorporate local proportions with servosystem correction
c                                                        /07-29-02/Sunder
c Ch6~Ch10, Ch12, Ch19~Ch23, Ch27~Ch36 /To incorporate rotaion and 
c affinity transform
c                                                      /08-12-02/Tuanfeng
c Ch11, Ch13~Ch18, Ch24~Ch26, Ch37 /To incorporate local proportions with 
c servosystem correction
c                                                      /08-13-02/Tuanfeng
c Ch38~Ch42 /To incorporate secondary soft propability P(A|C)
c                                                      /08-15-02/Tuanfeng
c Ch43~Ch65        /To incorporate multiple training images
c                                                      /08-16-02/Tuanfeng
c Ch66~Ch69     /To incorporate target proportion using Bayesian updating
c                                                      /08-25-02/Tuanfeng
c Ch70~Ch72     /To incorporate replicate number cmin
c                                                      /08-27-02/Tuanfeng
c Ch73~Ch83     /To remove the features of incoporating local proportion
c              into servsystem (Instead Local proportion taken as P(A|C))
c                                                      /10-13-02/Tuanfeng
c Ch84~Ch88    /To modify the formula which combines P(A|B) and P(A|C)
c                so that 0.0<=Tau1, Tau2<=1.0; 
c                Tau1=1.0, Tau2=0.0: only P(A|B) used; 
c                Tau1=0.0, Tau2=1.0: only P(A|C) used.
c                IF Tau1/Tau2 increases, impact of P(a|B)/P(A|C) increases
c                Tau1 and Tau2 could be chosen automatically. 
c                In addition, P(A|C) is used for all multiple grids, 
c                not only for several coarse grids 
c                                                      /11-29-02/Tuanfeng
c@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


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
      REAL, PARAMETER :: VERSION=10.000
      ! Maximum number of simulation grid nodes
      INTEGER, PARAMETER :: MAXXYZ = 70000
c Ch30 new begin: add global variables
      ! Maximum number of search trees for rotation factors
      INTEGER, PARAMETER :: MAXTREEANG=5
      ! Maximum number of search trees for affinity factors
      INTEGER, PARAMETER :: MAXTREEAFF=3
      ! Angle tolerance for using one category of angles
      REAL, PARAMETER :: ANGTOL=10
c Ch30 new end
      ! Maximum number of original sample data
      INTEGER, PARAMETER :: MAXDAT=1000
      REAL, PARAMETER :: EPSILON=1.0e-20, DEG2RAD=3.141592654/180.0
      INTEGER, PARAMETER :: UNEST=-99
      
c Ch63 new begin
      ! Maximum dimensions of the training image
      INTEGER, PARAMETER :: MAXXTR=250, MAXYTR=250, MAXZTR=1
c Ch64 new end
      
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
      INTEGER, ALLOCATABLE, DIMENSION(:) :: thres
      
      ! Target global pdf and target vertical proportion curve
      REAL, ALLOCATABLE, DIMENSION(:) :: pdf
      REAL, ALLOCATABLE, DIMENSION(:,:) :: vertpdf 
      
      ! Use target vertical proportion curve (0=no, 1=yes)
      INTEGER :: ivertprop
      
      ! Number of nodes simulated in each category for the full grid
      ! and for each horizontal layer    
      INTEGER, ALLOCATABLE, DIMENSION(:) :: nodcut
      INTEGER, ALLOCATABLE, DIMENSION(:,:) :: vertnodcut
      ! Dimension specifications of the simulation grid
      INTEGER :: nx, ny, nz, nxy, nxyz
      REAL :: xmn, xsiz, ymn, ysiz, zmn, zsiz

      ! Training image
c Ch58 add one dimension to consider imult
      INTEGER, ALLOCATABLE, DIMENSION (:,:,:,:) :: trainim

c Ch63 new begin: changed to array with dimension (nmult)      
      ! Dimensions of the training images
      INTEGER, ALLOCATABLE, DIMENSION (:) :: nxtr, nytr, nztr, 
     +                                      nxytr, nxyztr
c Ch63 new end
      
      ! Integer debugging level (0=none,1=normal,3=serious)
      INTEGER :: idbg
      
      ! Servosystem correction parameter
      REAL :: servocor
      
      ! Number of realizations to generate
      INTEGER :: nsim
      
      ! Realization and number of conditioning data retained
      INTEGER, ALLOCATABLE, DIMENSION (:,:,:) :: simim, numcd

c Ch62 new begin: changed to array with dimension (nmult)      
      ! Parameters defining the search ellipsoid
      REAL, ALLOCATABLE, DIMENSION (:) :: radius, radius1, radius2
      REAL, ALLOCATABLE, DIMENSION (:) :: sanis1, sanis2
      REAL, ALLOCATABLE, DIMENSION (:) :: sang1, sang2, sang3
c Ch62 new end
      REAL, DIMENSION (3,3) :: rotmat
      
      ! Maximum number of conditioning data retained,
      ! which is also the number of template nodes corresponding
      ! to previously simulated grids
      INTEGER :: prevnodmax
      ! Number of template nodes corresponding to current grid
      INTEGER :: curnodmax      
      
      ! Total number of grids
      INTEGER :: nmult
      
      ! Spacing between nodes of current grid
      INTEGER :: ncoarse
      
      ! Dimensions of current grid
      INTEGER :: nxcoarse, nycoarse, nzcoarse
      INTEGER :: nxycoarse, nxyzcoarse
      
      ! Number of nodes in the data template
      INTEGER :: nltemplate
      
      ! Relative coordinates of data template nodes
      INTEGER, ALLOCATABLE, DIMENSION (:) :: ixtemplate,iytemplate
      INTEGER, ALLOCATABLE, DIMENSION (:) :: iztemplate
      
      ! Number of times a conditioning data was located at each 
      ! template data location and number of times this data was dropped.
      INTEGER, ALLOCATABLE, DIMENSION (:) :: nlcd, nldropped
      
      ! Number of nodes simulated in the current grid
      INTEGER :: nodsim
      
      ! Conditioning data values at data template nodes
      INTEGER, ALLOCATABLE, DIMENSION (:) :: cnodev
      
      ! Number of conditioning data retained
      INTEGER :: ncnode
      
      ! Index of the nodes successively visited in the current grid (random path)
      INTEGER, DIMENSION(MAXXYZ) :: order
      ! Index of the multiple-grid offsets
      LOGICAL, DIMENSION(8) :: multgridoffset, prevgridoffset

c Ch73 old begin: remove codes.
c Ch1 new begin      

c      ! Use local proportions (0=no, 1=yes)
c      INTEGER :: ilocalprop
c      ! Local proportions
c      REAL, ALLOCATABLE, DIMENSION(:,:,:,:) :: localprop

c Ch1 new end      
c Ch11 new begin

c      ! Window size for local proportin
c      INTEGER :: nwx, nwy, nwz

c Ch11 new end
c Ch73 old end

c Ch6 new begin      
      ! Use rotation and affinity (0=no, 1=yes)
      INTEGER :: irotate
      ! Rotate and affinity data
      REAL, ALLOCATABLE, DIMENSION(:,:,:) :: rotangle
      ! categories for affinity factors
      INTEGER, ALLOCATABLE, DIMENSION(:,:,:) :: affclass      
c Ch6 new end

c Ch31 new begin
      ! number of angle categories
      INTEGER :: nangcat
      ! angles for angle categories
      REAL, DIMENSION(MAXTREEANG) :: angcat
      ! number of affinity categories
      INTEGER :: naffcat 
      ! affinity factors for affinity categories
      REAL, DIMENSION(MAXTREEAFF,3) :: affcat
c Ch31 new end

c Ch80 old begin: remove codes
c Ch13 new begin
c      ! Number of nodes simulated in each category in a local window
c      INTEGER, ALLOCATABLE, DIMENSION(:) :: localnodcut
c Ch13 new end
c Ch80 old end

c Ch38 new begin
      ! Use soft data and auto set of tau values (0=no, 1=yes)
      INTEGER :: isoft, iauto
      ! Used weight for combining soft information
      REAL :: tau1, tau2
      ! Probability for soft data
      REAL, ALLOCATABLE, DIMENSION (:,:,:,:) :: softprob 
c Ch38 new end

c Ch67 new begin
      ! Training image proportions
      REAL, ALLOCATABLE, DIMENSION (:,:) :: trpdf
c Ch67 new end

c Ch70 new begin
      ! Minimum number of replicates for training cpdf to be retained
      INTEGER :: cmin
c Ch70 new end
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
      CHARACTER (LEN=30) :: datafl, outfl, dbgfl
      CHARACTER (LEN=30) :: vertpropfl
c Ch60 change trainfl->trainfl(nmult)
      CHARACTER (LEN=30), ALLOCATABLE, DIMENSION(:) :: trainfl
      CHARACTER (LEN=30) :: rotanglefl,softfl
      CHARACTER (LEN=40) ::  str
      LOGICAL :: testfl
      INTEGER :: nvari, i, j, k, ioerror
      INTEGER :: icut, ntr, ix, iy, iz, ic, imult, kmult
      INTEGER :: npr, nrot, nsf
      INTEGER :: ixl, iyl, izl, ivrl
      INTEGER, ALLOCATABLE, DIMENSION(:) :: ivrltr
      INTEGER :: ixv
      REAL, ALLOCATABLE, DIMENSION(:) :: sampdf
! Ch32 new begin
      REAL :: angmax, angmin
! Ch32 new end

!
! Note VERSION number:
!
      WRITE(*,9999) VERSION
 9999 format(/' SNESIM Version: ',f8.3/)
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
      ALLOCATE(thres(ncut))
      READ(lin,*,err=98) (thres(icut), icut=1,ncut)
      WRITE(*,*) ' categories = ', (thres(icut), icut=1,ncut)
      ALLOCATE(pdf(ncut))
      READ(lin,*,err=98) (pdf(icut), icut=1,ncut)
      WRITE(*,*) ' target pdf = ', (pdf(icut), icut=1,ncut)
      ALLOCATE(nodcut(ncut))

c Ch 81 old begin: remove codes
c Ch14 new begin
c      ALLOCATE(localnodcut(ncut))
c Ch14 new end
c Ch 81 old end

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
      ALLOCATE(vertpdf(nz,ncut),vertnodcut(nz,ncut))
      READ(lin,*,err=98) servocor
      WRITE(*,*) ' servosystem correction = ',servocor
      IF(servocor>=1.OR.servocor<0) THEN  
         STOP 'ERROR: correction factor must be >=0, <1 !'
      END IF
      servocor=servocor/(1-servocor)
      WRITE(*,*) ' servosystem correction = ',servocor
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
      nx=max(1,nx)
      ny=max(1,ny)
      nz=max(1,nz)
      nxy  = nx*ny
      nxyz=nxy*nz
      
      READ(lin,*,err=98) ixv
      WRITE(*,*) ' random number seed = ',ixv
      
      ! Initialize the random seed of the simulation:
      seed(1)=ixv
      seed(2)=ixv+1
      CALL random_seed(PUT=seed(1:2))
      
      READ(lin,*,err=98) prevnodmax
      WRITE(*,*) ' maximum conditioning data = ',prevnodmax
      prevnodmax=max(1,prevnodmax)
      
      ! curnodmax is set to 4, which is reasonable, but quite arbitrary.
      curnodmax=4
      nltemplate=prevnodmax+curnodmax
      ALLOCATE(ixtemplate(nltemplate),iytemplate(nltemplate))
      ALLOCATE(iztemplate(nltemplate))
      ALLOCATE(nlcd(nltemplate),nldropped(nltemplate))
      ALLOCATE(cnodev(nltemplate))
c Ch71 new begin
      READ(lin,*,err=98) cmin
      WRITE(*,*) ' min. number of replicates = ',cmin
      IF(cmin<=0) THEN
         WRITE(*,*) 'cmin is not positive, reset to 1'
         cmin = 1
      END IF
c Ch72 new end


c Ch74 old begin: remove codes.
c Ch2 new begin

c      READ(lin,*,err=98) ilocalprop, nwx, nwy, nwz
c      IF(ilocalprop>1) THEN
c        STOP 'ERROR: ilocalprop must be 0 or 1'
c      END IF
c      WRITE(*,*) ' use local proportions = ',ilocalprop
c      READ(lin,'(a30)',err=98) localpropfl
c      CALL chknam(localpropfl,30)

c Ch2 new end
c Ch74 old end

c Ch39 new begin

      READ(lin,*,err=98) isoft, iauto
      IF(isoft>1) THEN
        STOP 'ERROR: isoft must be 0 or 1'
      END IF


      IF(iauto>1) THEN
        STOP 'ERROR: iauto must be 0 or 1'
      END IF

      WRITE(*,*) ' use soft data and auto set of tau= ',isoft, iauto

      READ(lin,*,err=98) tau1, tau2
      IF(tau1<0.or.tau1>1.or.tau2<0.or.tau2>1) THEN
        STOP 'ERROR: all tau values must be in [0, 1]'
      END IF

      IF(iauto==0) THEN
         WRITE(*,*) 'tau values: ', tau1, tau2
      ELSE
         WRITE(*,*) 'automatically combine P(A|B) and P(A|C)'
      END IF

      READ(lin,'(a30)',err=98) softfl
      CALL chknam(softfl,30)
      IF(isoft>0) THEN
         WRITE(*,*) 'Probability data file =', softfl
      END IF

c Ch39 new end

      
      
c Ch7 new begin
        
      READ(lin,*,err=98) irotate
      IF(irotate>1) THEN
        STOP 'ERROR: irotate must be 0 or 1'
      END IF
      WRITE(*,*) ' use rotation and affinity = ',irotate
      READ(lin,'(a30)',err=98) rotanglefl
      CALL chknam(rotanglefl,30)
      IF(irotate>0) THEN
         WRITE(*,*) 'Rotation and affinity file =', rotanglefl
      END IF
      
      READ(lin,*,err=98) naffcat
      WRITE(*,*) ' number of affinty categories = ', naffcat 
      IF(naffcat<=0.OR.naffcat>MAXTREEAFF) THEN
        WRITE(*,*) 'ERROR: naffcat must be >=1'
        WRITE(*,*) ' and <=MAXTREEAFF:',MAXTREEAFF
        STOP
      END IF
        
      DO i=1,naffcat
         READ(lin,*,err=98) (affcat(i,j),j=1,3)
         WRITE(*,*) ' affinity factors ax,ay,az = ', (affcat(i,j),j=1,3)
      END DO
c Ch7 new end

c Ch61 new begin: add do loop and change trainfl->trainfl(nmult)
      READ(lin,*,err=98) nmult
      WRITE(*,*) 'multiple grid simulation=', nmult

      ALLOCATE(trainfl(nmult))
      ALLOCATE(ivrltr(nmult))

      ALLOCATE(nxtr(nmult))
      ALLOCATE(nytr(nmult))
      ALLOCATE(nztr(nmult))
      ALLOCATE(nxytr(nmult))
      ALLOCATE(nxyztr(nmult))

      ALLOCATE(radius(nmult))
      ALLOCATE(radius1(nmult))
      ALLOCATE(radius2(nmult))
      ALLOCATE(sanis1(nmult))
      ALLOCATE(sanis2(nmult))
      ALLOCATE(sang1(nmult))
      ALLOCATE(sang2(nmult))
      ALLOCATE(sang3(nmult))
      
      DO imult=nmult,1,-1
         WRITE(*,*) 'Multiple grid ', imult
         kmult=imult   
         READ(lin,'(a30)',IOSTAT=ioerror) trainfl(imult)
         IF(ioerror<0.AND.imult==nmult) THEN
            STOP 'no training image exists!'
         ELSE IF(ioerror<0) THEN            
            trainfl(imult)=trainfl(kmult+1)
            WRITE(*,*) ' training image file = ',trainfl(imult)
            nxtr(imult)=nxtr(kmult+1)
            nytr(imult)=nytr(kmult+1)
            nztr(imult)=nztr(kmult+1)
            WRITE(*,*) ' training grid dimensions = ',
     +                   nxtr(imult),nytr(imult),nztr(imult) 
            ivrltr(imult)=ivrltr(kmult+1)  
            WRITE(*,*) ' column for variable = ',ivrltr(imult)
            radius(imult)=radius(kmult+1)
            radius1(imult)=radius1(kmult+1)
            radius2(imult)=radius2(kmult+1)
            WRITE(*,*) ' data search neighborhood radii = ',
     +                 radius(imult),radius1(imult),radius2(imult)
            sang1(imult)=sang1(kmult+1)
            sang2(imult)=sang2(kmult+1)
            sang3(imult)=sang3(kmult+1)
            WRITE(*,*) ' search anisotropy angles = ',sang1(imult),
     +                 sang2(imult),sang3(imult)

   
         ELSE 
            CALL chknam(trainfl(imult),30)
            WRITE(*,*) ' training image file = ',trainfl(imult)
            READ(lin,*,err=98) nxtr(imult),nytr(imult),nztr(imult)
            WRITE(*,*) ' training grid dimensions = ',
     +        nxtr(imult),nytr(imult),nztr(imult)
         
            READ(lin,*,err=98) ivrltr(imult)
            WRITE(*,*) ' column for variable = ',ivrltr(imult)
      
            READ(lin,*,err=98) radius(imult),radius1(imult),
     +                         radius2(imult)
            WRITE(*,*) ' data search neighborhood radii = ',
     +               radius(imult),radius1(imult),radius2(imult)
         
            READ(lin,*,err=98) sang1(imult),sang2(imult),sang3(imult)
            WRITE(*,*) ' search anisotropy angles = ',sang1(imult),
     +                 sang2(imult),sang3(imult)
         END IF


         IF(nxtr(imult)>MAXXTR.or.nytr(imult)>MAXYTR.or.
     +                               nztr(imult)>MAXZTR) THEN
            WRITE(*,*) 'ERROR: available train. grid size: ',
     +               MAXXTR,MAXYTR, MAXZTR
            WRITE(*,*) '       you have asked for : ',
     +               nxtr(imult),nytr(imult),nztr(imult)
            STOP
         END IF

         nxtr(imult)=max(1,nxtr(imult))
         nytr(imult)=max(1,nytr(imult))
         nztr(imult)=max(1,nztr(imult))
         nxytr(imult)= nxtr(imult)*nytr(imult) 
         nxyztr(imult)=nxytr(imult)*nztr(imult)
       
         IF(radius(imult)<EPSILON.OR.radius1(imult)<EPSILON.
     +          OR.radius2(imult)<EPSILON) 
     +        STOP 'radius must be greater than zero'
         sanis1(imult)=radius1(imult)/radius(imult)
         sanis2(imult)=radius2(imult)/radius(imult)
      END DO
c Ch61 new end

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
         ALLOCATE(sampdf(ncut))
         sampdf(1:ncut)=real(nodcut(1:ncut))/real(nd)
         DO icut=1,ncut
            WRITE(*,111) icut, sampdf(icut)
111         format(/,' Sample proportion of category ',
     +                      i4,' : ',f6.4) 
         END DO
         DEALLOCATE(sampdf)
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
! Now, read the training image if the file exists:
!
c Ch59 new begin: add one dimension for trainim to consider imult
      ALLOCATE(trainim(MAXXTR,MAXYTR,MAXZTR,nmult))
      ALLOCATE(trpdf(ncut,nmult))
      trpdf(1:ncut,1:nmult)=0.0

      DO imult=nmult,1,-1
         INQUIRE(file=trainfl(imult),exist=testfl)
         IF(.NOT.testfl) THEN
             STOP 'Training image file does not exist!'
         ELSE   
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
             DO
             READ(lin,*, IOSTAT=ioerror) (var(j),j=1,nvari)
             IF(ioerror<0) EXIT
             ntr=ntr+1
             IF(ntr>nxyztr(imult)) STOP ' ERROR exceeded nxyztr - 
     +                                    check inc file'
             iz=1+(ntr-1)/nxytr(imult)
             iy=1+(ntr-(iz-1)*nxytr(imult)-1)/nxtr(imult)
             ix=ntr-(iz-1)*nxytr(imult)-(iy-1)*nxtr(imult)
             DO icut=1,ncut
                IF(nint(var(ivrltr(imult)))==thres(icut)) THEN
                   trainim(ix,iy,iz,imult)=icut
                   trpdf(icut,imult) = trpdf(icut,imult) + 1
                   EXIT
                END IF
             END DO
          END DO
          CLOSE(lin)
        END IF
        trpdf(1:ncut,imult)=trpdf(1:ncut,imult)/nxyztr(imult)
      END DO
c Ch59 new end

c Ch75 old begin: remove codes.
c Ch3 new begin      
!
! Now, read the local proportion file, if it exists
! 
c      IF(ilocalprop==1) THEN
c       INQUIRE(file=localpropfl,exist=testfl)
c       IF(.NOT.testfl) THEN
c          WRITE(*,*)  'ERROR: local proportions file:', localpropfl
c          WRITE(*,*)   'dose not exist, check it and try again'
c          STOP
c       ELSE   
c          ALLOCATE(localprop(ncut,nx,ny,nz))
c          OPEN(lin,file=localpropfl,status='OLD')
c          READ(lin,*,err=97)
c          READ(lin,*,err=97) nvari
c          DO i=1,nvari
c             READ(lin,*,err=97)
c          END DO
      
!
! Read all the data until the end of the local proportions file:
! npr: number of data read in the local proportions file.
!
c          npr=0
c          DO
c             READ(lin,*, IOSTAT=ioerror) (var(j),j=1,nvari)
c             IF(ioerror<0) EXIT
c             npr=npr+1
c             IF(npr>nxyz) STOP ' ERROR exceeded nxyz - 
c     +                                  check inc file'
c             iz=1+(npr-1)/nxy
c             iy=1+(npr-(iz-1)*nxy-1)/nx
c             ix=npr-(iz-1)*nxy-(iy-1)*nx
c	     localprop(1:ncut,ix,iy,iz) = var(1:ncut)
c          END DO
c          CLOSE(lin)
c       END IF
c      END IF
c Ch3 new end
c Ch75 old end


c Ch40 new begin
!
! Now, read the soft probability file, if it exists
!
      IF(isoft==1) THEN
       INQUIRE(file=softfl,exist=testfl)
       IF(.NOT.testfl) THEN
          WRITE(*,*)  'ERROR: softprobability file:', softfl
          WRITE(*,*)   'dose not exist, check it and try again'
          STOP
       ELSE
          ALLOCATE(softprob(ncut,nx,ny,nz))
          OPEN(lin,file=softfl,status='OLD')
          READ(lin,*,err=97)
          READ(lin,*,err=97) nvari
          DO i=1,nvari
             READ(lin,*,err=97)
          END DO
          nsf=0
          DO
             READ(lin,*, IOSTAT=ioerror) (var(j),j=1,nvari)
             IF(ioerror<0) EXIT
             nsf=nsf+1
             IF(nsf>nxyz) STOP ' ERROR exceeded nxyz -
     +                                  check inc file'
             iz=1+(nsf-1)/nxy
             iy=1+(nsf-(iz-1)*nxy-1)/nx
             ix=nsf-(iz-1)*nxy-(iy-1)*nx
             softprob(1:ncut,ix,iy,iz) = var(1:ncut)
          END DO
          CLOSE(lin)
       END IF
      END IF
c Ch40 new end


!
! Read all the data until the end of the local proportions file:
! npr: number of data read in the local proportions file.
!



c Ch8 new begin 
!
! Now, read the rotation and affinity file, and categorize angles, 
! if it exists
! 
       nangcat=1
       angcat(1)=sang1(1)

       IF(irotate==1) THEN
       INQUIRE(file=rotanglefl,exist=testfl)
       IF(.NOT.testfl) THEN
          WRITE(*,*) 'Error: rotation and affinity file:', rotanglefl
          WRITE(*,*) 'dose not exist, check it and try again'
          STOP
       ELSE
          ALLOCATE(rotangle(nx,ny,nz))
          ALLOCATE(affclass(nx,ny,nz))
          OPEN(lin,file=rotanglefl,status='OLD')
          READ(lin,*,err=97)
          READ(lin,*,err=97) nvari
          IF(nvari/=2) STOP ' ERROR the rotation file
     +                        should contain 2 colums'             
          DO i=1,nvari
             READ(lin,*,err=97)
          END DO

! 
! Read all the data until the end of the angle and affinity file:
! nrot: number of data read in the local proportions file.
!
          nrot=0
          angmax=-1.0e21
          angmin=+1.0e21
          DO
             READ(lin,*, IOSTAT=ioerror) (var(j),j=1,nvari)
             IF(ioerror<0) EXIT
             nrot=nrot+1
             IF(nrot>nxyz) STOP ' ERROR exceeded nxyz -
     +                                  check inc file'
             iz=1+(nrot-1)/nxy  
             iy=1+(nrot-(iz-1)*nxy-1)/nx
             ix=nrot-(iz-1)*nxy-(iy-1)*nx
             rotangle(ix,iy,iz) = var(1)
             affclass(ix,iy,iz) = nint(var(2))
             IF(var(1)<angmin) angmin=var(1)
             IF(var(1)>angmax) angmax=var(1)
          END DO
          CLOSE(lin)
        END IF
!
! Categorize angles
!
        IF(abs(angmax-angmin)>ANGTOL) THEN
           nangcat=MAXTREEANG
           IF(MAXTREEANG>1) THEN
             DO i=1,nangcat
                angcat(i)=angmin+(i-1)*(angmax-angmin)
     +                                 /real(MAXTREEANG-1)
             END DO
           END IF
        ELSE
         nangcat=1
         angcat(1)=(angmin+angmax)/2.0
        END IF
      END IF 
c Ch8 new end



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
 18   format('0.5                           ',
     +       '- servosystem parameter (0=no correction)') 
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
      WRITE(lun,55)
 55   format('16                            ',
     +       '- max number of conditioning primary data')

      WRITE(lun,56)
 56   format('10                            ', 
     +       '- min. replicates number')
c Ch76 old begin: remove codes.
c Ch5 new begin
c      WRITE(lun,65)
c 65   format('0   20  20  1                 ',
c     +       '- cond. to LP (0=N, 1=Y), window size')
c 
c      WRITE(lun,66)
c 66   format('localprop.dat                 ',
c     +        '- file for local proportions') 
c Ch5 new end
c Ch76 old end

c Ch9 new begin
      WRITE(lun,65)
 65   format('1     0                     ',
     +       '- condtion to LP (0=no, 1=yes), flag for iauto')
    
      WRITE(lun,655)
 655  format('1.0     1.0                     ',
     +       '- two weighting factors to combine P(A|B) and P(A|C)')

      WRITE(lun,66)
 66   format('localprop.dat                 ',
     +        '- file for local proportions')
            
      WRITE(lun,67)
 67   format('1                             ',
     +       '- condition to rotation and affinity (0=no, 1=yes)')
      WRITE(lun,68)
 68   format('rotangle.dat                  ',
     +        '- file for rotation and affinity')
      
      WRITE(lun,69)
 69   format('3                             ',
     +       '- number of affinity categories')
      WRITE(lun,70)
 70   format('1.0  1.0  1.0                 ',
     +       '- affinity factors (X,Y,Z)     ')
      WRITE(lun,71)
 71   format('1.0  0.6  1.0                 ',
     +       '- affinity factors             ')
      WRITE(lun,72)
 72   format('1.0  2.0  1.0                 ',   
     +       '- affinity factors             ')
c Ch9 new end

      WRITE(lun,555)
 555  format('5                             ',
     +       '- number of multiple grids')
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
         INTEGER, DIMENSION(:), POINTER ::  repl
         TYPE(streenode), DIMENSION(:), POINTER :: next
      END TYPE streenode
      
      CONTAINS

c Ch43: add imult here SetRotMat()->SetRotMat(imult)     
      SUBROUTINE SetRotMat(imult)
      IMPLICIT NONE
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
c
c
c OUTPUT PARAMETER:
c
c   rotmat               Rotation matrix accounting for anisotropy
c
c
c-----------------------------------------------------------------------
c Ch55 new begin
      ! Delcare dummy arguments
      INTEGER, INTENT(IN) :: imult
c Ch55 new end      
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
c Ch44 add imult here: sang123->sang123(imult)

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
c Ch47 add imult here: CreateTemplate()->CreateTemplate(imult)      
      SUBROUTINE CreateTemplate(imult)
      IMPLICIT NONE
c-----------------------------------------------------------------------
c
c                     Create data template
c                     ********************
c
c We want to establish a search for nearby nodes in order of closeness 
c as defined by the distance corresponding to the search ellipse.
c The data template will consist of the nearest 'prevnodmax' nodes of the
c previously simulated grids, and the nearest 'curnodmax' nodes of the
c current grid.
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
c  MAXXYZ          	Maximum size of simulation grid
c  radius       	Maximum search radius
c  rotmat               Rotation matrix accounting for anisotropy
c
c
c OUTPUT VARIABLES:  
c
c  nltemplate          	Number of nodes in the data template
c  i[x,y,z]template    	Relative coordinates of those nodes
c
c
c EXTERNAL REFERENCES:
c
c  sortem          	Sorts multiple arrays in ascending order
c
c
c
c-----------------------------------------------------------------------
c Ch56 new begin
      ! Delcare dummy arguments
      INTEGER, INTENT(IN) :: imult
c Ch56 new end

      ! Declare local variables
      INTEGER :: i,j,k,ic,jc,kc,il,n, nlsearch
      INTEGER :: ncdata, prevncdata, location, templatesize
      REAL :: xx,yy,zz,hsqd,radsqd,cont
      INTEGER :: nctx, ncty, nctz, nctxy, nctxyz
      REAL, DIMENSION(MAXXYZ) :: tmp
      INTEGER, DIMENSION(MAXXYZ) :: ordercd,c,d,e,f,g,h
      radsqd=radius(imult)*radius(imult)

!
! Size of the data search neighborhood
!
      nctx=min(((nx-1)/2),nltemplate)
      ncty=min(((ny-1)/2),nltemplate)
      nctz=min(((nz-1)/2),nltemplate)
!
! Debugging output:
!
      WRITE(ldbg,*) 'Search for conditioning data'
      WRITE(ldbg,*) 'The maximum range in each coordinate direction is:'
      WRITE(ldbg,*) '          X direction: ',nctx*xsiz*ncoarse
      WRITE(ldbg,*) '          Y direction: ',ncty*ysiz*ncoarse
      WRITE(ldbg,*) '          Z direction: ',nctz*zsiz*ncoarse
      WRITE(ldbg,*) 'Conditioning data are not searched ', 
     +              'beyond this distance!'
!
! Now, set up the table of distances to the unknown, and keep track of 
! the node offsets that are within the search radius:
!
      nlsearch = 0

c Ch48 new begin
      CALL SetRotMat(imult)
c Ch48 new end

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
                  ordercd(nlsearch)=real((kc-1)*nxy+(jc-1)*nx+ic)
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
      
      ncdata=0
      prevncdata=0
      templatesize=0

      DO il=2,nlsearch
         k=int((ordercd(il)-1)/nxy) + 1
         j=int((ordercd(il)-(k-1)*nxy-1)/nx)+1
         i=ordercd(il)-(k-1)*nxy-(j-1)*nx
         i=i-nctx-1
         j=j-ncty-1
         k=k-nctz-1
         location=mod(abs(i),2)+mod(abs(j),2)*2+mod(abs(k),2)*4+1
         IF(multgridoffset(location)) THEN
            IF(prevgridoffset(location).AND.prevncdata<curnodmax) THEN
               templatesize=templatesize+1
               ixtemplate(templatesize)=i
               iytemplate(templatesize)=j
               iztemplate(templatesize)=k
!               write(*,*) i,j,k
               prevncdata=prevncdata+1
            END IF
            IF(.NOT.prevgridoffset(location)) THEN
               templatesize=templatesize+1
               ixtemplate(templatesize)=i
               iytemplate(templatesize)=j
               iztemplate(templatesize)=k
!               write(*,*) i,j,k
               ncdata=ncdata+1
               if(ncdata>=prevnodmax) EXIT
            END IF
         END IF
      END DO
      nltemplate=templatesize
!
! Debugging output if requested:
!
      IF(idbg>0) THEN
         WRITE(ldbg,*) 'There are ',nltemplate,' nodes in the template '
         DO i=1,nltemplate
             write(ldbg,100) i,ixtemplate(i),iytemplate(i),iztemplate(i) 
         END DO
 100     format('Node ',i5,' at ',3i5)
      ENDIF
      END SUBROUTINE CreateTemplate
c-----------------------------------------------------------------------
c Ch49 old begin: no calculation of multiple grids needed, it is given
c      SUBROUTINE CalculateMultGridNumber ()
c      IMPLICIT NONE
c-----------------------------------------------------------------------
c
c        Calculate number of multiple grids
c        **********************************
c
c The number of multiple grids to be simulated is calculated as follows: 
c the data template corresponding to the coarsest simulation grid should have
c a larger extent than the search neighborhood 
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
c      ! Declare local variables
c      INTEGER :: ind,n
c      REAL :: xx,yy,zz,hsqd,cont,maxdist
c      LOGICAL :: ndinside
c      multgridoffset(1:8)=.TRUE.
c      prevgridoffset(1:8)=.FALSE.
c      CALL CreateTemplate()
c      maxdist=max(radius,radius1)*max(radius,radius1)
c      ncoarse=1
c      nmult=0
c      ndinside=.TRUE.
c      DO
c      ! Check if all the nodes of the data template are inside the search neighborhood
c         DO ind=1,nltemplate
c            xx=xsiz*ixtemplate(ind)*ncoarse
c            yy=ysiz*iytemplate(ind)*ncoarse
c            zz=zsiz*iztemplate(ind)*ncoarse
c            hsqd = 0.0
c            DO n=1,3
c               cont=rotmat(n,1)*xx+rotmat(n,2)*yy+rotmat(n,3)*zz
c               hsqd = hsqd + cont*cont
c            END DO
c            IF(hsqd>maxdist) ndinside=.FALSE.
c         END DO
c         IF(ndinside) THEN
c            nmult=nmult+1
c            ncoarse=ncoarse*2
c         ELSE
c            EXIT
c         END IF
c      END DO
c      END SUBROUTINE CalculateMultGridNumber
c
c Ch49 old end
c-------------------------------------------------------------------
      SUBROUTINE RandomPath()
      IMPLICIT NONE
      
c----------------------------------------------------------------------------
c
c                    Work out a random path
c                    **********************
c
c This subroutine works out a random path that visits all nodes of
c the current grid.
c
c
c INPUT VARIABLES:
c
c  nxyzcoarse  	    Number of nodes in the current grid 
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

c--------------------------------------------------------------------------
c Ch14 new begin


c Ch 82 old begin: remove codes
c      SUBROUTINE SearchClosestNodes(ix,iy,iz)
c      USE parameter
c      IMPLICIT NONE
c-----------------------------------------------------------------------
c This subroutine calculate the number for simulated category with
c a specified local window.
c
c INPUT VARIABLES: 
c ix,iy,iz            Index of the point currently being simulated
c simim               Realization so far
c nwx,nwy,nwz         specified window size
c OUTPUT VARIABLES:
c localnodcut
c
c------------------------------------------------------------------------
c
c  
c      ! Declare dummy arguments
c      INTEGER, INTENT(IN) :: ix, iy, iz
c
c      ! Declare local variables
c      INTEGER :: i, j, k, i1, j1, k1
c
c      localnodcut(1:ncut)=0
c
c 
c      DO k1=-nwz,nwz
c      DO j1=-nwy,nwy
c      DO i1=-nwx,nwx
c         i=ix+i1
c         j=iy+j1
c         k=iz+k1
c         IF(i>=1.and.i<=nx.and.j>=1.and.j<=ny.and.k>=1.and.k<=nz)
c     +      THEN
c            IF(simim(i,j,k)>UNEST) THEN
c               localnodcut(int(simim(i,j,k)))=
c     +               localnodcut(int(simim(i,j,k)))+1
c            END IF
c          END IF
c      END DO
c      END DO
c      END DO
c
c                     
c      END SUBROUTINE SearchClosestNodes
                  
c--------------------------------------------------------------------
c Ch14 new end
c Ch82 old end
c
c
c-------------------------------------------------------------------
c Ch57 add imult here: 
      SUBROUTINE DrawValue (ix, iy, iz, cpdf,imult)
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
      REAL, DIMENSION (:) :: cpdf
      INTEGER, INTENT(IN) :: ix,iy,iz,imult
      ! Declare local variables
      INTEGER :: ic
      REAL, ALLOCATABLE, DIMENSION  (:) :: ccdf
      REAL :: p, total, totalnodcut
c Ch83 old begin: remove codes
c Ch16 new begin
c      REAL :: totallocalnodcut
c Ch16 new end



c Ch37 new begin
c      totallocalnodcut=real(MAX(sum(localnodcut(1:ncut)),1))
c Ch37 new end
c Ch83 old end
!
! Apply the servosystem correction:
!
      IF(ivertprop==1) THEN
         totalnodcut=real(MAX(sum(vertnodcut(iz,1:ncut)),1))
      ELSE
         totalnodcut=real(MAX(sum(nodcut(1:ncut)),1))
      END IF
      DO ic=1, ncut

c Ch77 old begin: remove codes
c Ch17 new begin
c        IF(ilocalprop==1) THEN
c          IF(localprop(ic,ix,iy,iz)<0.05) cpdf(ic)=0.0
c          IF(localprop(ic,ix,iy,iz)>0.95) cpdf(ic)=1.0
c        END IF
c Ch17 new end
c Ch77 old end

         IF(cpdf(ic)>0.05.AND.cpdf(ic)<0.95) THEN
c Ch25 new begin: at the first coarse grid, no correction needed
           IF(imult<=nmult-1) THEN
c Ch25 new end
              IF(ivertprop==1) THEN
                 cpdf(ic)=cpdf(ic)+servocor*
     +      (vertpdf(iz,ic)-real(vertnodcut(iz,ic))/totalnodcut)
              ELSE
c Ch4 old begin
c                cpdf(ic)=cpdf(ic)+
c     +          servocor*(pdf(ic)-real(nodcut(ic))/totalnodcut)
c Ch4 old end

c Ch 78 new begin: recover the codes.
                cpdf(ic)=cpdf(ic)+
     +          servocor*(pdf(ic)-real(nodcut(ic))/totalnodcut)
c Ch 78 new end

c Ch 79 old begin: remove codes.
c Ch4 new begin
c                IF(ilocalprop==1.AND.imult==nmult-1.AND.
c     +             totallocalnodcut>=(prevnodmax/4.0)) THEN
c                    cpdf(ic)=cpdf(ic)+
c     +           servocor*(localprop(ic,ix,iy,iz)-
c     +              real(localnodcut(ic))/totallocalnodcut)
c                 ELSE
c                    cpdf(ic)=cpdf(ic)+
c     +         servocor*(pdf(ic)-real(nodcut(ic))/totalnodcut)
c	         END IF
c Ch4 new end
c Ch 79 old end
              END IF   
              IF(cpdf(ic)<0.0) cpdf(ic)=0.0
              IF(cpdf(ic)>1.0) cpdf(ic)=1.0
c Ch26 new begin: pair Ch25
           END IF
c Ch26 new end
       END IF
      END DO
      
      total=sum(cpdf(1:ncut))
      cpdf(1:ncut)=cpdf(1:ncut)/total
      IF(idbg>1) THEN
         WRITE(ldbg,210) 
210      format('After servosystem correction:')
         DO ic=1,ncut
            WRITE(ldbg,211) thres(ic), cpdf(ic)
211         format('Cpdf for category ', i3, ' : ', f6.4)
         END DO
      END IF
      ALLOCATE(ccdf(ncut))
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
      DEALLOCATE(ccdf)
      	  
      nodcut(simim(ix,iy,iz))=nodcut(simim(ix,iy,iz))+1
      IF(ivertprop==1) 
     + vertnodcut(iz,simim(ix,iy,iz))=vertnodcut(iz,simim(ix,iy,iz))+1
     
      IF(idbg>1) WRITE(ldbg,212) ix,iy,iz, thres(simim(ix,iy,iz))
212   format('Category simulated at ', i5, i5, i5, ': ', i3)
      
      END SUBROUTINE DrawValue	
c--------------------------------------------------------------------
c Ch51 add inult here InferTree(stree)->InferTree(stree,imult)
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
      TYPE(streenode) :: stree(MAXTREEANG,MAXTREEAFF)
c Ch52 new begin
      INTEGER, INTENT(IN) :: imult
c Ch52 new end
      ! Declare local variables
      INTEGER :: ix, iy, iz, ccut, itree1, itree2

!
! Loop over all the nodes of the training image:
!
      DO iz=1,nztr(imult)
         DO iy=1,nytr(imult)
            DO ix=1,nxtr(imult)
         
! ccut: current central value:
               ccut=trainim(ix,iy,iz,imult)
c Ch33 old begin:
c              CALL UpdateTree(stree,ix,iy,iz,ccut,1)
c Ch33 old end

c Ch34 new begin:
               DO itree1=1,nangcat
                  DO itree2=1,naffcat
                     CALL UpdateTree(itree1,itree2,
     +                    stree(itree1,itree2), imult, ix,iy,iz,ccut,1)
                  END DO
               END DO
c Ch34 new end
            END DO
         END DO
      END DO
      
      END SUBROUTINE InferTree
c-------- -------------------------------------------------------------------
      RECURSIVE SUBROUTINE UpdateTree(itree1,itree2,
     +                       onestree,imult,ix,iy,iz,ccut,icd)
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
c  
c
c
c OUTPUT VARIABLES: Search tree stree updated
c
c
c____________________________________________________________________________
      ! Declare dummy arguments
      TYPE(streenode) :: onestree
      INTEGER, INTENT(IN) :: imult,ix,iy,iz,ccut,icd,itree1,itree2
      ! Declare local variables
      INTEGER :: icut,ixh,iyh,izh,ic,err

c Ch20 new begin: introduce local variables
      REAL    :: xcor, ycor, alpha
c Ch20 new end

c Ch21 new begin
! Rotate and then do affinity for data event.

      alpha = -(angcat(itree1)-sang1(1))*DEG2RAD

      xcor  = cos(alpha)*ixtemplate(icd)*ncoarse +
     +               sin(alpha)*iytemplate(icd)*ncoarse
      ycor  = -sin(alpha)*ixtemplate(icd)*ncoarse +
     +                cos(alpha)*iytemplate(icd)*ncoarse
c Ch21 new end

c Ch22 old begin     
! First, calculate the coordinates of the location
! currently visited in the data template:
c      ixh=ix+ixtemplate(icd)*ncoarse
c      iyh=iy+iytemplate(icd)*ncoarse
c      izh=iz+iztemplate(icd)*ncoarse
c Ch22 old end
c Ch23 new begin   
       ixh=ix+nint(affcat(itree2,1)*xcor)
       iyh=iy+nint(affcat(itree2,2)*ycor) 
       izh=iz+affcat(itree2,3)*iztemplate(icd)*ncoarse
c Ch23 new end
      
! Check if the current template location is within the training image:
c Ch53 add imult here: nxyztr->nxyztr(imult)      

      IF(ixh>=1.AND.ixh<=nxtr(imult).AND.iyh>=1.AND.
     +   iyh<=nytr(imult).AND.izh>=1.AND.izh<=nztr(imult)) THEN

c Ch54 add imult here: trainim(ixh,iyh,izh)->trainim(ixh,iyh,izh,imult)
         icut=trainim(ixh,iyh,izh,imult)
         
! If the search tree node corresponding to the current conditioning
! configuration does not exit, create it: 
         
         IF(.NOT.ASSOCIATED(onestree%next)) THEN
              ! Create a new node:
              ALLOCATE(onestree%next(ncut),STAT=err)
              IF(err/=0) STOP 'Machine out of memory'
              ! Initialize the new node:
              DO ic=1,ncut
                 NULLIFY(onestree%next(ic)%repl)
                 NULLIFY(onestree%next(ic)%next)
              END DO
         END IF
            
         IF(.NOT.ASSOCIATED(onestree%next(icut)%repl)) THEN
               ALLOCATE(onestree%next(icut)%repl(ncut),STAT=err)
               IF(err/=0) STOP 'Machine out of memory'
               onestree%next(icut)%repl(1:ncut)=0
         END IF
         
! Update the node corresponding to the current central value: 
         onestree%next(icut)%repl(ccut)=
     +   onestree%next(icut)%repl(ccut)+1
     
! If locations need still be visited in the data template, visit them
! and update the search tree accordingly:  
  
         IF(icd<nltemplate)
     +         CALL UpdateTree(itree1,itree2,
     +               onestree%next(icut),imult,ix,iy,iz,ccut,icd+1)
      END IF
       
      END SUBROUTINE UpdateTree
      
       
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
      IF(ASSOCIATED(stree%repl)) DEALLOCATE(stree%repl)
      
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
c of the current grid to be simulated.
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
      REAL :: xx, yy, zz, test, testassigned
      REAL :: xmncoarse, ymncoarse, xsizcoarse, ysizcoarse
      REAL :: zmncoarse, zsizcoarse
      INTEGER :: jxbase, jybase, jzbase, jxoffset, jyoffset, jzoffset
      INTEGER :: jxassigned, jyassigned, jzassigned, location
      LOGICAL :: unassigned
      INTEGER, ALLOCATABLE, DIMENSION (:,:,:) :: simtemp
!
! Define specifications of the current multiple grid.
!
      xmncoarse=xmn
      ymncoarse=ymn
      zmncoarse=zmn
      xsizcoarse=xsiz*ncoarse
      ysizcoarse=ysiz*ncoarse
      zsizcoarse=zsiz*ncoarse
      ALLOCATE(simtemp(nxcoarse,nycoarse,nzcoarse))
      simtemp(1:nxcoarse,1:nycoarse,1:nzcoarse)=UNEST
!
! Loop over all the original sample data
!    
      DO id=1,nd
!
! Calculate the coordinates of the closest simulation grid node:
!
         IF(nxcoarse>1) THEN
            jxbase=int((x(id)-xmn)/xsizcoarse)+1
         ELSE
            jxbase=1
         END IF
         IF(nycoarse>1) THEN
            jybase=int((y(id)-ymn)/ysizcoarse)+1
         ELSE
            jybase=1
         END IF
         IF(nzcoarse>1) THEN
            jzbase=int((z(id)-zmn)/zsizcoarse)+1
         ELSE
            jzbase=1
         END IF
         unassigned=.TRUE.
         
         DO jxoffset=0,1
            DO jyoffset=0,1
               DO jzoffset=0,1
                  jx=jxbase+jxoffset
                  jy=jybase+jyoffset
                  jz=jzbase+jzoffset
                  IF(jx>=1.AND.jx<=nxcoarse.AND.jy>=1.AND.jy<=nycoarse
     +                 .AND.jz>=1.AND.jz<=nzcoarse) THEN
                     location=mod(abs(jx),2)+mod(abs(jy),2)*2+
     +                    mod(abs(jz),2)*4+1
                     IF(multgridoffset(location)) THEN
                        xx=xmncoarse +(jx-1)*xsizcoarse
                        yy=ymncoarse +(jy-1)*ysizcoarse
                        zz=zmncoarse +(jz-1)*zsizcoarse
                        test=abs(xx-x(id))+abs(yy-y(id))+abs(zz-z(id))
                        IF(unassigned) THEN
                           unassigned=.FALSE.
                           testassigned=test
                           jxassigned=jx
                           jyassigned=jy
                           jzassigned=jz
                        ELSE IF(test<testassigned) THEN
                           testassigned=test
                           jxassigned=jx
                           jyassigned=jy
                           jzassigned=jz
                        END IF
                     END IF
                  END IF
               END DO
            END DO
         END DO
         
         IF(.NOT.unassigned) THEN
            IF(simtemp(jxassigned, jyassigned, jzassigned)/=UNEST) THEN
               id2=simtemp(jxassigned, jyassigned, jzassigned)
               xx=xmncoarse +(jxassigned-1)*xsizcoarse
               yy=ymncoarse +(jyassigned-1)*ysizcoarse
               zz=zmncoarse +(jzassigned-1)*zsizcoarse
               test = abs(xx-x(id2)) + abs(yy-y(id2)) + abs(zz-z(id2))
               IF(testassigned<test) 
     +              simtemp(jxassigned, jyassigned, jzassigned)=id
            ELSE
               simtemp(jxassigned, jyassigned, jzassigned)=id
            END IF                  
         END IF
      END DO
!
! Now, enter data values into the simulated grid:
!
      DO jz=1,nzcoarse
         DO jy=1,nycoarse
      	    DO jx=1,nxcoarse
               id=simtemp(jx,jy,jz)
               IF(id>0) THEN
                  iz=(jz-1)*ncoarse+1
                  iy=(jy-1)*ncoarse+1
                  ix=(jx-1)*ncoarse+1
! Check if there is already a simulated value; if yes, replace it.
                  IF(simim(ix,iy,iz)>0) THEN
                     nodcut(simim(ix,iy,iz))=nodcut(simim(ix,iy,iz))-1
                     IF(ivertprop==1) vertnodcut(iz,simim(ix,iy,iz))=
     +                    vertnodcut(iz,simim(ix,iy,iz))-1
                  END IF
                  simim(ix,iy,iz) = vr(id)  
                  nodcut(simim(ix,iy,iz))=nodcut(simim(ix,iy,iz))+1
                  IF(ivertprop==1) vertnodcut(iz,simim(ix,iy,iz))=
     +                 vertnodcut(iz,simim(ix,iy,iz))+1
             
! Indicates with a special value assigned to numcd that a sample data
! has been assigned to the node.
                  numcd(ix,iy,iz)=10*UNEST           
               END IF
	    END DO	
         END DO
      END DO
      DEALLOCATE(simtemp)
 
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
      SUBROUTINE InferCpdfTree(ix,iy,iz,cpdf,imult,stree)
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
      INTEGER, INTENT(IN) :: ix, iy, iz,imult
      REAL, DIMENSION (:), INTENT(OUT) :: cpdf
      TYPE(streenode) :: stree(MAXTREEANG,MAXTREEAFF)
      
      ! Declare local variables
      INTEGER :: i, j, k, ind, maxind, icut , sumrepl
      INTEGER, ALLOCATABLE, DIMENSION (:) :: replicate
c Ch10 new begin
      INTEGER :: itree, mtree1, mtree2
      REAL :: vmin,tmpv
c Ch10 new end
     

!
! First, spiral away from the node being simulated and node all 
! the nearby nodes that have been simulated
!
      ncnode=0

c Ch12 new begin: accept rotation angles and affinity values:
      mtree1=1
      mtree2=1
      vmin=+1.0e21

      IF(irotate==1) THEN
        DO itree=1,nangcat
           IF(abs(angcat(itree)-rotangle(ix,iy,iz))<vmin) THEN
              mtree1=itree
              vmin=abs(angcat(itree)-rotangle(ix,iy,iz))
           END IF
        END DO 
        mtree2=affclass(ix,iy,iz)             
      END IF
c Ch12 new end


! maxind: location index of the furthest away conditioning datum      
      maxind=0

! Consider all the nearby nodes until enough have been found:
      DO ind=1,nltemplate
         IF(ncnode==prevnodmax) EXIT

         i=ix+ixtemplate(ind)*ncoarse
         j=iy+iytemplate(ind)*ncoarse
         k=iz+iztemplate(ind)*ncoarse

         cnodev(ind)=UNEST

         IF(i>=1.and.i<=nx.and.j>=1.and.j<=ny.and.
     +      k>=1.and.k<=nz) THEN
            cnodev(ind)=simim(i,j,k)
            IF(cnodev(ind)>UNEST) THEN
               nlcd(ind)=
     +         nlcd(ind)+1
               ncnode=ncnode+1
               maxind=ind
            IF(idbg>2) WRITE(ldbg,1204) ind,ixtemplate(ind)*ncoarse,
     +           iytemplate(ind)*ncoarse,iztemplate(ind)*ncoarse,
     +           thres(cnodev(ind))
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

      ALLOCATE(replicate(ncut))

      DO
        replicate(1:ncut)=0

c Ch27 modify stree to stree(mtree)
        CALL RetrieveCpdfTree(1,stree(mtree1,mtree2),replicate,maxind)
        sumrepl=SUM(replicate(1:ncut))
        IF(idbg>2) WRITE(ldbg,*) 'Training replicates:', sumrepl
! Check if enough training replicates: if yes, calculate the cpdf,
! otherwise drop the furthest away datum
c Ch72 introduce cmin here
        IF(sumrepl>=cmin) THEN
           cpdf(1:ncut)=real(replicate(1:ncut))/real(sumrepl)
           EXIT
        ELSE
           ncnode=ncnode-1
           nldropped(maxind)=nldropped(maxind)+1
           IF(idbg>2) WRITE(ldbg,404) 
404      format('Not enough replicates, drop the furthest away CD.')
           IF(idbg>2) WRITE(ldbg,405) ncnode
405      format('Infer cpdf for', i3, ' CD.')
            DO 
               maxind=maxind-1
               IF(maxind==0) EXIT
               IF(cnodev(maxind)/=UNEST) EXIT
            END DO
         END IF
      END DO

      DEALLOCATE(replicate)
c Ch66 new begin: update ccdf using target pdf
      DO icut=1,ncut
         tmpv=(pdf(icut)-trpdf(icut,imult))*cpdf(icut)+
     +           trpdf(icut,imult)*(1.0-pdf(icut))
         cpdf(icut)=cpdf(icut)*(1.0-trpdf(icut,imult))*pdf(icut)/
     +              max(tmpv,EPSILON)
      END DO
c Ch66 new end
      
      
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
      RECURSIVE SUBROUTINE RetrieveCpdfTree(cdind,onestree,
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
      INTEGER, DIMENSION (:), INTENT(INOUT) :: replicate
      TYPE(streenode) :: onestree
      ! Declare local variables
      INTEGER :: ic
      
! cdind: current level in the search tree.      
      IF(cdind<=maxind) THEN
         ic=cnodev(cdind)
         
c Ch28 modify all stree to onestree in this subroutine:
         
! If there is a conditioning data at the template location cdind, 
! consider only that conditioning value, otherwise sum up over all
! values possibly taken by the location cdind:
         
         IF(ASSOCIATED(onestree%next)) THEN   
            IF(ic>UNEST) THEN 
               CALL RetrieveCpdfTree(cdind+1,
     +            onestree%next(ic),replicate,maxind)
            ELSE
              DO ic=1,ncut
                 CALL RetrieveCpdfTree(cdind+1,
     +              onestree%next(ic),replicate,maxind)
              END DO
            END IF
         END IF
      ELSE
         IF(ASSOCIATED(onestree%repl)) 
     +      replicate(1:ncut)=replicate(1:ncut)+onestree%repl(1:ncut)
      END IF
      END SUBROUTINE RetrieveCpdfTree
      
c-------------------------------------------------------------------
      SUBROUTINE SimulationTree (stree,imult)
      IMPLICIT NONE
      
c----------------------------------------------------------------------------
c
c                    Simulate the current grid
c                    *************************
c
c This subroutine simulates the current grid.
c The conditional simulation is performed by sequential simulation of all
c the nodes visited by a random path.
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
c OUTPUT VARIABLE: All the nodes of the current grid are simulated
c
c
c____________________________________________________________________________
      ! Declare dummy arguments
      TYPE(streenode) :: stree(MAXTREEANG,MAXTREEAFF)
      INTEGER, INTENT(IN) :: imult 
      
      ! Declare local variables
      INTEGER :: in, ix, iy, iz, irepo, ncnode, ic
      REAL, ALLOCATABLE, DIMENSION  (:) :: cpdf
      INTEGER :: jx,jy,jz,location
        
      irepo=max(1,min((nxyzcoarse/10),10000))
!
! Main loop over all the nodes of the current multiple grid:
!            
      ALLOCATE(cpdf(ncut))
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
         location=mod(abs(jx),2)+mod(abs(jy),2)*2+mod(abs(jz),2)*4+1
         
         IF(simim(ix, iy, iz)<0.AND.multgridoffset(location)) THEN
            nodsim=nodsim+1

c Ch83 old begin: remove codes.
c Ch15 new begin
! Calculate locally simulated nodes
c            CALL SearchClosestNodes(ix,iy,iz)
c Ch15 new end
c Ch83 old end

c Ch68 old begin
! Infer the local cpdf using the search tree
c            CALL InferCpdfTree(ix, iy, iz, cpdf, stree)
! Draw a random number and assign a value to this node:
c Ch68 old end

c Ch69 new begin: introduce imult here
! Infer the local cpdf using the search tree
            CALL InferCpdfTree(ix, iy, iz, cpdf, imult, stree)
! Draw a random number and assign a value to this node:
c Ch69 new end

c Ch41 new begin
! Update the cpdf to account for collocated soft datum if used:
! Only use soft data on the first two coarse grids
           IF(isoft==1) THEN
             CALL UpdateForSecondary (ix, iy, iz, cpdf, imult)
           END IF
c Ch41 new end

c Ch18 old begin
c           CALL DrawValue(ix, iy, iz, cpdf)
c Ch18 old end

c Ch24 new begin: introduce imult here                                    
            CALL DrawValue(ix, iy, iz, cpdf,imult)
c Ch24 new end
         END IF
      END DO
      DEALLOCATE(cpdf)
      
      END SUBROUTINE SimulationTree

c Ch42 new begin: add a subrotine to consider soft information

c-------------------------------------------------------------------
      SUBROUTINE UpdateForSecondary (ix, iy, iz, cpdf, imult)
      IMPLICIT NONE
 
c----------------------------------------------------------------------------
c  
c               Update cpdf to account for secondary information
c               ************************************************
c
c  This subroutine updates the local pdf conditional to hard data
c  at (ix,iy,iz) to account for the collocated soft datum value 
c  (method 2) 
c
c
c INPUT VARIABLES:
c
c  ix,iy,iz             Index of the point currently being simulated
c  cpdf                 Local cpdf
c
c
c
c OUTPUT VARIABLES:
c
c  simim                Realization so far
c  nodcut               Number of nodes simulated in each category so far
c
c
c____________________________________________________________________________
         
      ! Declare dummy arguments
      REAL, DIMENSION  (:), INTENT(INOUT) :: cpdf
      INTEGER, INTENT(IN) :: ix,iy,iz,imult
            
      ! Declare local variables
      INTEGER :: ic, isec
      REAL,  ALLOCATABLE, DIMENSION (:) :: softcpdf, tmptau1, tmptau2
      REAL*8, ALLOCATABLE, DIMENSION (:) :: arel,brel,crel,xrel
      REAL :: total

! Allocate spaces for arrays
      ALLOCATE(softcpdf(ncut))
      ALLOCATE(tmptau1(ncut))
      ALLOCATE(tmptau2(ncut))
      ALLOCATE(arel(ncut))
      ALLOCATE(brel(ncut))
      ALLOCATE(crel(ncut))
      ALLOCATE(xrel(ncut))

! If a probability conditional to the hard data only is equal to 1, then 
! no updating is required.

      softcpdf(1:ncut)=softprob(1:ncut,ix,iy,iz)

      tmptau1(1:ncut) = tau1
      tmptau2(1:ncut) = tau2

c Ch87 new begin: optimally set tau values
      IF(iauto==1) THEN
         DO ic=1,ncut
            IF(cpdf(ic)>=pdf(ic)) THEN
          tmptau1(ic) = (cpdf(ic) - pdf(ic))/(1 - pdf(ic))
            ELSE
               tmptau1(ic) = (pdf(ic) - cpdf(ic))/pdf(ic)
            END IF
         END DO

         DO ic=1,ncut
            IF(softcpdf(ic)>=pdf(ic)) THEN
          tmptau2(ic) = (softcpdf(ic) - pdf(ic))/(1 - pdf(ic))
            ELSE
               tmptau2(ic) = (pdf(ic) - softcpdf(ic))/pdf(ic)
            END IF
         END DO
      END IF
c Ch87 new end

c Ch84 begin of old
c     IF(imult<nmult-1) RETURN
c Ch84 end  
      IF(maxval(cpdf(1:ncut))<(1-EPSILON)) THEN  
         IF(maxval(softcpdf(1:ncut))>(1-EPSILON)) THEN
            cpdf(1:ncut)=softcpdf(1:ncut)
         ELSE
            arel(1:ncut)=pdf(1:ncut)/max(1-pdf(1:ncut),EPSILON)
            brel(1:ncut)=cpdf(1:ncut)/max(1-cpdf(1:ncut),EPSILON)
       crel(1:ncut)=softcpdf(1:ncut)/max(1-softcpdf(1:ncut),EPSILON)
c Ch85 old begin
c            xrel(1:ncut)=brel(1:ncut)*
c     +          (crel(1:ncut)/max(arel(1:ncut),EPSILON))**omega
c Ch85 old end

c Ch86 new begin: symmetric constrain on P(A|B) and P(A|C) 
c 0.0=<tau1 and tau2<=1.0
            xrel(1:ncut)=arel(1:ncut)*
     +  (brel(1:ncut)/max(arel(1:ncut),EPSILON))**tmptau1(1:ncut)*
     +       (crel(1:ncut)/max(arel(1:ncut),EPSILON))**tmptau2(1:ncut)
c Ch86 new end      
            cpdf(1:ncut)=xrel(1:ncut)/(1+xrel(1:ncut)) 
            total=sum(cpdf(1:ncut))
            cpdf(1:ncut)=cpdf(1:ncut)/total
         END IF

         IF(idbg>1) THEN
            WRITE(ldbg,170)
170         format('After updating for collocated soft datum:')
            DO ic=1,ncut
               WRITE(ldbg,171) thres(ic), cpdf(ic)
171            format('Cpdf for category ', i3, ' : ', f6.4)
            END DO
         END IF
      END IF    
            
! Deallocate spaces

      DEALLOCATE(softcpdf)
      DEALLOCATE(arel,brel,crel,xrel)
     
      END SUBROUTINE UpdateForSecondary

c Ch42 new end: end of the added subroutine
                        
c-------------------------------------------------------------------
      SUBROUTINE SimulateOneGrid(imult)
      IMPLICIT NONE
      
c----------------------------------------------------------------------------
c
c                    Simulate the current grid
c                    *************************
c
c This subroutine, which calls 'SimulationTree', simulates the current grid.
c The conditional simulation is achieved by sequential simulation of all
c the nodes visited by a random path.
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
      INTEGER, INTENT(IN) :: imult
      
      ! Declare local variables
      INTEGER :: ind, itree1, itree2
      REAL :: meanCD
      TYPE(streenode) :: searchtree(MAXTREEANG,MAXTREEAFF)
! Create data template:
c Ch46 add imulat here: CreateTemplate()->CreateTemplate(imult)            
      CALL CreateTemplate(imult)
               
      nlcd(1:nltemplate)=0
      nldropped(1:nltemplate)=0
      nodsim=0
            
! Builds the search tree corresponding to the current multiple grid:

c Ch29 modify searchtree to searchtree(:,:)

      DO itree1=1,nangcat   
          DO itree2=1,naffcat
            ALLOCATE(searchtree(itree1,itree2)%repl(ncut))
         searchtree(itree1,itree2)%repl(1:ncut)=int(pdf(1:ncut)*nxyz)
            NULLIFY(searchtree(itree1,itree2)%next)
          END DO
      END DO

c Ch50 add imult here: InferTree(searchtree)->InferTree(searchtree,imult)
      CALL InferTree(searchtree,imult)
         
! Assign data to the current multiple grid simulation:
      CALL AssignData()
! Work out a random path for this realization:
      CALL RandomPath()
! Perform simulation:
      CALL SimulationTree(searchtree,imult)
! Unassign the data:
      IF(imult>1) CALL UnassignData()
      IF(idbg>0) THEN
         WRITE(ldbg,*)
         WRITE(ldbg,*) 'Some statistics on the data template' 
         DO ind=1,nltemplate
            WRITE(ldbg,*)
            WRITE(ldbg,505) ixtemplate(ind),iytemplate(ind),
     +           iztemplate(ind)
 505        format('At location ',i4,i4,i4, ':')
            WRITE(ldbg,506) 100.0*real(nlcd(ind))/real(nodsim)
 506        format('a conditioning datum was present',f5.1,
     +           '% of the time')
            IF(nlcd(ind)>0) WRITE(ldbg,507) 100.0*
     +           real(nldropped(ind))/real(nlcd(ind))
 507        format('this conditioning datum was dropped',f5.1,
     +           '% of the time')   
            WRITE(ldbg,508) 100.0*
     +           real(nlcd(ind)-nldropped(ind))/real(nodsim)
 508        format('so this location was actually used',f5.1,
     +           '% of the time')      
         END DO
      END IF
               
! Deallocates the search tree:
c Ch35 old begin:         
c     CALL DeallocateTree(searchtree,1)
c Ch35 old end
 
c Ch36 new begin:
      DO itree1=1,nangcat
          DO itree2=1,naffcat
            CALL DeallocateTree(searchtree(itree1,itree2),1)
          END DO
      END DO
c Ch36 new end
           
! Calculate the mean number of CD finally retained in average 
! for the current grid:
      IF(idbg>0) THEN
         CALL MeanNumberCD(meanCD)
         WRITE(ldbg,173) meanCD
 173     format(/,' Mean number of conditioning data retained: ',f6.1)
      END IF
      
      END SUBROUTINE SimulateOneGrid
            
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
      REAL, ALLOCATABLE, DIMENSION (:) :: simpdf
      
! Read the parameters and data:
      CALL ReadParm
      ncoarse=1
c Ch45 old begin
! Set up rotation matrix to compute anisotropic distances
! for conditioning data search
c     CALL SetRotMat()
! Calculate number of multiple-grids
c      ncoarse=1
c      CALL CalculateMultGridNumber
c Ch45 old end

c Ch65 new begin
      ncoarse=1
      multgridoffset(1:8) = .TRUE.
      prevgridoffset(1:8) = .FALSE.
c Ch65 new end

      WRITE(*,*)
      WRITE(*,*) 'Number of multiple-grids:',nmult
      
! Initialize the simulation
      ALLOCATE(simim(nx,ny,nz), numcd(nx,ny,nz))
!
! Main loop over all the simulations:
!
      DO isim=1, nsim
!      
! Initialize the simulation and assign the data to the closest grid nodes:
!
         simim(1:nx,1:ny,1:nz)=UNEST
         numcd(1:nx,1:ny,1:nz)=UNEST
         nodcut(1:ncut)=0
         IF(ivertprop==1) vertnodcut(1:nz,1:ncut)=0
        
         WRITE(*,*)
         WRITE(*,*) 'Working on realization number ',isim
         
         IF(idbg>0) THEN
            WRITE(ldbg,2000) isim
2000        format(/,/' Working on realization number:',i4)
         END IF
! Loop over multiple-grids
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
     
            IF(imult==nmult) THEN
               CALL SimulateOneGrid(imult)
            ELSE
               multgridoffset(1)=.TRUE.
               prevgridoffset(1)=.TRUE.
               multgridoffset(2:8)=.FALSE.
               prevgridoffset(2:8)=.FALSE.
! simulate first subgrid
               multgridoffset(8)=.TRUE.
               IF(nzcoarse>1) CALL SimulateOneGrid(imult)
               prevgridoffset(8)=.TRUE.
! simulate second subgrid
               multgridoffset(4)=.TRUE.
               multgridoffset(5)=.TRUE.
               CALL SimulateOneGrid(imult)
               prevgridoffset(4)=.TRUE.
               prevgridoffset(5)=.TRUE.
     
! simulate third subgrid
               multgridoffset(2)=.TRUE.
               multgridoffset(3)=.TRUE.
               multgridoffset(6)=.TRUE.
               multgridoffset(7)=.TRUE.
               CALL SimulateOneGrid(imult)
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
         ALLOCATE(simpdf(ncut))
         simpdf(1:ncut)=real(nodcut(1:ncut))/real(nxyz)
         DO ic=1,ncut
            WRITE(*,112) ic, simpdf(ic)
112         format(/,' Simulated proportion of category ',
     +                      i4,' : ',f6.4) 
         END DO
         DEALLOCATE(simpdf)
!
! Calculate the mean number of CD retained:
!
         WRITE(*,113) real(totalncd)/real(numncd)
113      format(/,' Mean number of conditioning data retained: ',f6.1)
      END DO
      CLOSE(lout)
      
! Finished:
      DEALLOCATE(simim, numcd, trainim)
      DEALLOCATE(thres,pdf,nodcut,vertpdf,vertnodcut)
      DEALLOCATE(ixtemplate,iytemplate, iztemplate)
      DEALLOCATE(nlcd,nldropped)
      DEALLOCATE(cnodev)

c Ch19 new begin
c      DEALLOCATE(localprop)
c      DEALLOCATE(rotangle)
c      DEALLOCATE(affclass)
c      DEALLOCATE(softprob)
c      DEALLOCATE(nxtr,nytr,nztr,nxytr,nxyztr)
c      DEALLOCATE(sanis1,sanis2) 
c      DEALLOCATE(radius,radius1,radius2,sang1,sang2,sang3)
c      DEALLOCATE(trpdf)
c Ch19 new end
      
      WRITE(*,9998) VERSION
 9998 format(/' SNESIM Version: ',f8.3,' Finished'/)
  
      END PROGRAM snesim
