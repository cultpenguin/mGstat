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
c The following Parameters control static dimensioning for SGSIM:
c
c   MAXX      maximum nodes in X
c   MAXY      maximum nodes in Y
c   MAXZ      maximum nodes in Z
c   MAXCTX    maximum X points in covariance table (ODD number)
c   MAXCTY    maximum Y points in covariance table (ODD number)
c   MAXCTZ    maximum Z points in covariance table (ODD number)
c   MAXSBX    maximum super block nodes in X direction
c   MAXSBY    maximum super block nodes in Y direction
c   MAXSBZ    maximum super block nodes in Z direction
c   MAXDAT    maximum number of data
c   MAXNOD    maximum number of previously simulated nodes to use
c   MAXSAM    maximum number of data for one simulation
c   MAXNST    maximum number of nested structures for variogram
c   MAXVOLS   maximum number of volumes type data to include 
c   MAXDINVOL MAXimum number of Data IN a VOLumes 
c   MAXQUAN   maxiumum number of quantiles to use in DSSIM mode
c   MAXMVLOOK maxiumum number of Mean and Var values to lookup in DSSIM mode
c
c-----------------------------------------------------------------------
c
c User Adjustable Parameters:
c
      integer MAXX, MAXY, MAXZ, MAXCTX, MAXCTY, MAXCTZ
      integer MAXSBX, MAXSBY, MAXSBZ, MAXDAT, MAXNOD, MAXSAM
      integer MAXNST, MAXREF, MAXCAT, MV, MAXVOLS, MAXDINVOL

      parameter(MAXX   =   801, MAXY   = 801, MAXZ   = 1,
     +          MAXCTX =  MAXX, MAXCTY =MAXY, MAXCTZ =MAXZ,
     +          MAXSBX =    21, MAXSBY =  21, MAXSBZ = 11,
     +          MAXDAT = 50000, MAXNOD =  1448, MAXSAM = 148,
     +          MAXNST =     4, MAXREF=10000,MAXCAT=24, 
     +          MV=20         , MAXVOLS=1 , MAXDINVOL=1,
     +		MAXQUAN=501,MAXMVLOOK=201)



c
c Fixed Parameters:
c
      integer MAXKR1, MAXKR2, MAXROT, MAXCXY, MAXXYZ, MAXSB, MXYZ
      integer MAXGEOMDATA
      real VERSION, UNEST, EPSLON
      parameter(MAXKR1=MAXNOD+MAXSAM+1,MAXKR2=MAXKR1*MAXKR1,
     +          MAXROT=MAXNST+1,MAXCXY=MAXCTX*MAXCTY,
     +          MAXXYZ=MAXCTX*MAXCTY*MAXCTZ,MAXSB=MAXSBX*MAXSBY*MAXSBZ,
     +          MXYZ=MAXX*MAXY*MAXZ,UNEST=-9999999.0,EPSLON=1.0e-20,
     +          MAXGEOMDATA=MAXVOLS*MAXDINVOL,
     +          VERSION=2.0)
c
c ACORN parameters:
c
      integer KORDEI, MAXOP1, MAXINT
      parameter(KORDEI=12,MAXOP1=KORDEI+1,MAXINT=2**30)
c
c Variable Declaration:
c
      real      x(MAXDAT),y(MAXDAT),z(MAXDAT),vr(MAXDAT),wt(MAXDAT),
     +          vrtr(MAXDAT),vrgtr(MAXDAT),close(MAXDAT),sec(MAXDAT),
     +          sim(MXYZ),lvm(MXYZ),tmp(MXYZ),order(MXYZ),
     +          c0(1),cc(MAXNST),aa(MAXNST),ang1(MAXNST),ang2(MAXNST),
     +          ang3(MAXNST),anis1(MAXNST),anis2(MAXNST),
     +          covtab(MAXCTX,MAXCTY,MAXCTZ), avepor(MAXX,MAXY),
     + 		datacov(MAXVOLS,MAXVOLS),
     +          cnodex(MAXNOD),cnodey(MAXNOD),cnodez(MAXNOD),
     +          cnodev(MAXNOD),vra(MAXKR1),vrea(MAXKR1),ltpar,
     +          krgvar(MXYZ), utpar, pkr
      integer   cnodeindex(MAXNOD)
      real      rcdf(MAXREF),rvr(MAXREF),dcdf(MAXDAT),dvr(MXYZ),
     +          indx(MAXDAT),fuzzcat(MAXDAT),catcdf(MAXCAT)

      real*8    rotmat(MAXROT,3,3),r(MAXKR1),rr(MAXKR1),s(MAXKR1),
     +          a(MAXKR2)
      integer   ltail,utail,sstrat,mults,nisb(MAXSB),nst(1),
     +          it(MAXNST),icnode(MAXNOD), novar(MXYZ)
      integer   category(MAXDAT), ncut, inovar
      integer*2 ixnode(MAXXYZ),iynode(MAXXYZ),iznode(MAXXYZ),
     +          ixsbtosr(8*MAXSB),iysbtosr(8*MAXSB),izsbtosr(8*MAXSB)
      real      wtt, vrt, wtd, vrd
      real	ckurt, colocorr, zmaxvar
      integer   wx, wy, wz,  isim, idrawopt   
      character distin*40, localfl*40, outfl*40, transoutfl*40      
      character lambdafl*40

      integer   ibt,ibtw,nbt,mask(MXYZ)
      real	bootvar(MAXDAT),bootwt(MAXDAT),btmean,btvar
      real	bootcdf(MAXDAT)	
c FOR VOLUMES
      integer   nvol,ndatainvol(MAXVOLS)
      real	volobs(MAXVOLS)
      real	volvar(MAXVOLS)
      real	volobs_ref(MAXVOLS)  
      real	volx(MAXVOLS,MAXDINVOL)	
      real	voly(MAXVOLS,MAXDINVOL)	
      real	volz(MAXVOLS,MAXDINVOL)	
      real	voll(MAXVOLS,MAXDINVOL)	
      integer	voli(MAXVOLS,MAXDINVOL)	
      integer   nusev,usev(MAXVOLS)	
      integer   musevols,nusevols
      real 	accept_fract
      integer   shuffvol,shuffinvol,densitypr
      integer   lout_mean,lout_std,lout_krig
	
c FOR Histrogram Reproduction ..
      real 	condlookup_mean(MAXMVLOOK,MAXMVLOOK)
      real 	condlookup_var(MAXMVLOOK,MAXMVLOOK)
      real 	condlookup_cpdf(MAXMVLOOK,MAXMVLOOK,MAXQUAN)
      integer n_Gmean,n_Gvar,n_q,n_monte,discrete
      real min_Gmean,max_Gmean
      real min_Gvar,max_Gvar

      real x_quan(MAXQUAN)
      real x_quan_center(MAXQUAN)

c 	estimation/simulation
      integer doestimation

c
c The matrices below are covariance lookup tables. 
C they can optionally be excluded
c
	real*8      cv2v(MAXVOLS,MAXVOLS)
        real*8      cd2v(MXYZ,MAXVOLS)
      	integer read_covtable, read_lambda, read_volnh, read_randpath

c
c Common Blocks:
c
      integer ixv(MAXOP1), itr(MAXOP1)
      integer ixv2(MAXOP1), itr2(MAXOP1)

      common /kurto/  ckurt, idrawopt, pkr
	
      common /iaco/   ixv, itr
c      common /iaco/   ixv(MAXOP1), itr(MAXOP1)

      common /iaco2/   ixv2, itr2

      common /generl/ nx,ny,nz,xsiz,ysiz,zsiz,xmn,ymn,zmn,nxy,nxyz,
     +                nd,x,y,z,vr,wt,ntr,vrtr,vrgtr,sec,idbg,
     +                lin,lout,ldbg,llvm,lkv,icollvm,nvaril,ktype,
     +                colocorr, ivar,  
     +                ltail,ltpar,utail,utpar,zmin,zmax,varred,skgmean,
     +                avepor, porvar, icond, gvar,
     +	              lout_mean, lout_std, lout_krig
     +	              shuffvol,shuffinvol,densitypr,
     +                musevols,nusevols,accept_fract,nusev,usev

      common /volume/ nvol,ndatainvol,volobs,
     +	volvar,volobs_ref,volx,voly,volz,voll,voli

      common /simula/ doestimation,isim, nsim,sim,lvm,mask

      common /search/ radius,radsqd,sang1,sang2,sang3,sanis1,sanis2,
     +                noct,nclose,close,ndmin,ndmax,sstrat,mults,nmult

      common /cova3d/ nst,it,cmax,c0,cc,aa,ang1,ang2,ang3,
     +                anis1,anis2,isrot,cv2v,cd2v,read_covtable,
     +		      read_lambda, read_volnh, read_randpath

      common /cd/     datacov


      common /clooku/ nctx,ncty,nctz,covtab,nlooku,ncnode,icnode,
     + 	              cnodeindex,
     +                cnodex,cnodey,cnodez,cnodev,nodmax,ixnode,iynode,
     +                iznode

      common /krigev/ rotmat,r,rr,s,a,vra,cbb, krgvar, inovar, novar
     +                ,zmaxvar,lambdafl
      common /transcon/  ivrr, iwtr, wx,wy, wz, 
     +		      icoll, wtfac, rn, distin, 
     +		      localfl, outfl, tmin, tmax,transoutfl, itrans,
     +                ivrd, iwtd, rcdf, rvr, dcdf, dvr, indx, fuzzcat, 
     +                catcdf,  category, wtt, vrt, wtd, vrd, ncut

      common /bt/   ibt,ibtw,nbt,bootvar,bootwt,btmean,btvar,bootcdf
	
      common /hrdssim/   condlookup_mean,condlookup_var,
     +               condlookup_cpdf,n_mean,n_var,n_monte,
     + 	             discrete,n_q,
     +               min_Gmean, max_Gmean, n_Gmean, 
     +               min_Gvar, max_Gvar, n_Gvar,
     +               x_quan
