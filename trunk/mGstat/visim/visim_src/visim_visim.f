      subroutine visim
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
c     Conditional Simulation of a 3-D Rectangular Grid
c     ************************************************
c     
c     This subroutine generates 3-D realizations of a sequential process with
c     a given autocovariance model, and conditional to input sample data.
c     The conditional simulation is achieved by sequential simulation of all
c     the nodes visited by a random path.
c     
c     
c
c     PROGRAM NOTES:
c     
c     1. The three dimensional anisotropy parameters, i.e., of the search
c     ellipse and variogram ranges are described in section 2.3 of the
c     manual.   The variogram parameters are described in the same place
c     
c     2. The original data and previously simulated grid nodes can be
c     searched separately.  There can be a different maximum number of
c     each and a minimum number of original data can be specified
c     to restrict simulation beyond the limits of the data.  The
c     closeness of previously simulated grid nodes is measured according
c     to the variogram structural distance.
c     
c     
c     
c     INPUT VARIABLES:
c     
c     nd               Number of data (no missing values)
c     x,y,z(nd)        coordinates of the data
c     vr(nd)           sample data 
c     
c     nx,ny,nz         Number of blocks in X,Y, and Z
c     xmn,ymn,zmn      Coordinate at the center of the first Block
c     xsiz,ysiz,zsiz   spacing of the grid nodes (block size)
c     
c     nsim             number of simulations
c     sim              the current realization across the field
c     idbg             integer debugging level (0=none,2=normal,4=serious)
c     ldbg             unit number for the debugging output
c     lout             unit number for the output
c     
c     radius           Maximum search radius
c     sang1            Azimuth angle of the principal search direction
c     sang2            Dip angle of the principal search direction
c     sang3            Third rotation angle of the search ellipse
c     sanis1           Anisotropy for the dip angle
c     sanis2           Anisotropy for the plunge angle
c     ndmin            Minimum number of data required before sim
c     ndmax            Maximum number of samples for simulation
c     noct             Maximum number per octant if an octant search is
c     desired (if <= 0, then no octant search)
c     
c     nodmax           Maximum number of previously simulated grid nodes
c     to consider in the simulation.  The structural
c                      variogram distance is used to identify close ones
c     
c     c0               Nugget constant (isotropic).
c     cc(nst)          Multiplicative factor of each nested structure.
c     aa(nst)          Parameter "a" of each nested structure.
c     it(nst)          Type of nested structures (1=sph,2=exp,3=gau,4=pow)
c     ang1(nst)        Azimuth angle for the principal direction
c     ang2(nst)        Dip angle for the principal direction
c     ang3(nst)        Third rotation angle to rotate the two minor
c     directions around the principal direction
c     anis1(nst)       Anisotropy (radius in minor direction at 90
c     degrees from "ang1" divided by the principal
c     radius in direction "ang1")
c     anis2(nst)       Anisotropy (radius in minor direction at 90 degrees
c     vertical from "ang1" divided by the principal
c     radius in direction "ang1")
c     
c     
c OUTPUT VARIABLES:  Simulated Values are written to "lout"
c     
c     
c
c EXTERNAL REFERENCES:
c
c     super            Sets up the super block search of original data
c     search           Search for nearby data values
c     ctable           Builds a covariance table and "spiral" search
c     srchnd           Search for nearby simulated grid nodes
c     sqdist           computes anisotropic squared distance
c     sortem           sorts multiple arrays in ascending order (separate)
c     cova3            Calculates the covariance given a variogram model
c     krige            Sets up and solves either the SK or OK system
c     ksol             Linear system solver using Gaussian elimination
c
c     
c     
c     Concepts taken from F. Alabert and E. Isaaks
c     
c-----------------------------------------------------------------------
      include  'visim.inc'
      real      randnu(1),var(10),vobs,derr
      real*8    p,acorni,cp,oldcp,w
      logical   testind
      real cstdev_tmp
      real sim_mean(MXYZ), sim_std(MXYZ)
      real sumderr,sumerr,temp
      real meantmh,stdtmh
      real gvar_org, gmean_org, cbb_org

      character tmpfl*80
c      integer lout_krig

c
c      open(8, file='checkord.dat', status = 'unknown')

c
c Set up the rotation/anisotropy matrices that are needed for the
c variogram and search.
c
                  
c      write(ldbg,*) 'Setting up rotation matrices',
c     +     ' for variogram and search'
      do is=1,nst(1)
         call setrot(ang1(is),ang2(is),ang3(is),anis1(is),anis2(is), 
     +        is,MAXROT,rotmat)   
      end do
      isrot = MAXNST + 1
      call setrot(sang1,sang2,sang3,sanis1,sanis2,isrot,MAXROT,rotmat)
      
c     
c     Set up the super block search:
c     
      if(sstrat.eq.0) then
c         write(ldbg,*) '****Setting up super block search strategy'
         nsec = 1
         call setsupr(nx,xmn,xsiz,ny,ymn,ysiz,nz,zmn,zsiz,nd,x,y,z,
     +        vr,wt,nsec,sec,sec2,sec3,MAXSBX,MAXSBY,MAXSBZ,
     +        nisb,nxsup,xmnsup,xsizsup,nysup,ymnsup,ysizsup,
     +        nzsup,zmnsup,zsizsup)
         call picksup(nxsup,xsizsup,nysup,ysizsup,nzsup,zsizsup,
     +        isrot,MAXROT,rotmat,radsqd,nsbtosr,ixsbtosr,
     +        iysbtosr,izsbtosr)
      end if
      
c     
c     Set up the covariance table and the spiral search:
c     

      call ctable


      
c     In the case of a collocated cokriging, secondary variable is avalaible
c     at every grid for each realization.  Read in the secondary data
c     distribution for realization number larger than 1. The secondary data
c     for the first relization has already been read in read_par subroutine. 
      
      if(isim.gt.1.and.ktype.eq.4) then
         write(*,*)
         write(*,*) ' Reading next secondary model'
         index = 0
         do iz=1,nz
            do iy=1,ny
               do ix=1,nx
                  index = index + 1
                  read(llvm,*,end=977)(var(j),j=1,nvaril)
                  lvm(index) = var(icollvm)
                  sim(index) = real(index)
               end do
            end do
         end do
         write(*,*) ' Building CDF from secondary model'
         call sortem(1,nxyz,lvm,1,sim,c,d,e,f,g,h)
         oldcp = 0.0
         cp    = 0.0
         do i=1,nxyz
            cp =  cp + dble(1.0/real(nxyz))
            w  = (cp + oldcp)/2.0
            lvm(i) = lvm(i) * w 
            oldcp  =  cp
         end do
         write(*,*) ' Restoring order of secondary model'
         call sortem(1,nxyz,sim,1,lvm,c,d,e,f,g,h)
 977     continue
      end if
c     
c     Work out a random path for this realization:
c     
      do ind=1,nxyz
         sim(ind)   = real(acorni(idum))
         order(ind) = ind
      end do
c      p=real(acorni(idum))


c
c     The multiple grid search works with multiples of 4 (yes, that is
c     somewhat arbitrary):
c     
      if (densitypr.eq.0) then
         mults=1;
         nmult=4;
      else
         mults=0;
         nmult=4;
      endif

c      write(*,*) 'mults,nmult,densitypr=',mults,nmult,densitypr
      
      if(mults.eq.1) then
         do imult=1,nmult
            nnz = max(1,nz/(imult*4))
            nny = max(1,ny/(imult*4))
            nnx = max(1,nx/(imult*4))
            jz  = 1
            jy  = 1
            jx  = 1
            do iz=1,nnz
               if(nnz.gt.1) jz = iz*imult*4
               do iy=1,nny
                  if(nny.gt.1) jy = iy*imult*4
                  do ix=1,nnx
                     if(nnx.gt.1) jx = ix*imult*4
                     index = jx + (jy-1)*nx + (jz-1)*nxy
                     sim(index) = sim(index) - imult
                  end do
               end do
            end do
         end do
      end if


      if (idbg.gt.0) write(*,*) '-----------------------------'
      if (idbg.gt.-1) write(*,*) 'Working on realization number ',isim


c
c     SETUP THE RANDOM PATH - NEW STYLE
      call rayrandpath(order)

c      sequential 1,2,3,4.... path
c      do i=1,nxyz
c        order(i)=i
c      enddo
871    format(A,'_',A)

c      READ/WRITE RANDOM PATH FROM/TO DISK? 
      if(read_randpath.eq.0) then      
	  write(98) (order(i),i=1,nxyz)          
c	  write(98) (sim(i),i=1,nxyz)          
      endif	
c	write(*,*) 'read_randpath=',read_randpath
      if(read_randpath.eq.1) then      
	  read(98) (order(i),i=1,nxyz)
c	  read(98) (sim(i),i=1,nxyz)
      endif	


c     OPEN HANDLE FOR KRIGING MEAN + VAR

      lout_krig = 60
      write(tmpfl,871) 'kriging',outfl
      open(lout_krig, file=tmpfl, status = 'unknown')


	  
c     
c     Initialize the simulation:
c     
      do ind=1,nxyz
         sim(ind) = UNEST
      end do
c     
c     Assign the sample data to the closest grid node:
c     
      TINY = 0.0001
c     write(ldbg,*) nd
      do id=1,nd
         call getindx(nx,xmn,xsiz,x(id),ix,testind)
         call getindx(ny,ymn,ysiz,y(id),iy,testind)
         call getindx(nz,zmn,zsiz,z(id),iz,testind)
         ind = ix + (iy-1)*nx + (iz-1)*nxy
         xx  = xmn + real(ix-1)*xsiz
         yy  = ymn + real(iy-1)*ysiz
         zz  = zmn + real(iz-1)*zsiz
         
c         WRITE(ldbg,*) X(ID), Y(ID), Z(ID)
c         WRITE(ldbg,*) IX, IY, IZ
c         WRITE(ldbg,*) XX, YY, ZZ
c         WRITE(*,*) X(ID), Y(ID), Z(ID)
c          WRITE(*,*) IX, IY, IZ, vr(id)
c          WRITE(*,*) XX, YY, ZZ, 
        
c     coordinates of x, y and z
c     
         test = abs(xx-x(id)) + abs(yy-y(id)) + abs(zz-z(id))
c     
c     Assign sample data to the closest grid node unles there is a close data:
c     
         
         
         if(sstrat.eq.1) then
            if(sim(ind).ge.0.0) then
               id2 = int(sim(ind)+0.5)
               test2 = abs(xx-x(id2)) + abs(yy-y(id2))
     +              + abs(zz-z(id2))
               if(test.le.test2) sim(ind) = real(id)
c               write(ldbg,102) id,id2
            else
               sim(ind) = real(id)
            end if
         end if
         
         
c     
c     In case when data are not assigned to grid node, Assign a
c     flag(10.0*UNEST) with a very negative value, so that this node does not
c     get simulated:
c     
         if(sstrat.eq.0.and.test.le.TINY) then
            sim(ind)=10.0*UNEST
         end if
      end do
c     c This is the end of loop over all sample data id=1,nd
      
      
 102  format(' WARNING data values ',2i5,' are both assigned to ',
     +     /,'         the same node - taking the closest')
      
c     
c     Now, enter data values into the simulated grid in the case when data
c     are assigned to grid node, when (id.gt.0) satisfies.  
c     
      do ind=1,nxyz
         id = int(sim(ind)+0.5)
         if(id.gt.0) sim(ind) = vr(id)
      end do
      irepo = max(1,min((nxyz/10),10000))
      
c     
c     MAIN LOOP OVER ALL THE NODES:
c     
      
      if (idbg.gt.0) print*, 'ok before the main loop?'
      
      neg = 0
      nsmall0 = 0
      nsmall = 0
      nlarge = 0

      if (doestimation.eq.1) then
         do ind=1,nxyz
            sim_mean(ind) = sim(ind)
            sim_std(ind) = 0
         end do
      endif
      
      
c     do ind=1,nxyz
c     write(*,*) 'i,sim=',ind,sim(ind)
c     end do
c     write(*,*) 'sim(1)=',sim(1)
      
      do in=1,nxyz
        if((in/500*500 .eq.in).AND.(idbg.ge.0)) write(*,103)in
c     if(in/1*1 .eq.in) write(*,103)in
c     write(*,103)in
 103     format('************   currently on node 
     +        ',i9,' *****')
         
         
         
c     
c     Figure out the location of this point and make sure it has
c     not been assigned a value already:
c     
         
c     order() keeps the simulation random path
         
         index = int(order(in)+0.5)
         
c     WRITE(*, *) 'SIM(', INDEX, ')=', SIM(INDEX),order(in)
c         WRITE(ldbg, *) 'SIM(', INDEX, ')=', SIM(INDEX)
c         if (((sim(index).gt.(UNEST+EPSLON).or.
c     +        sim(index).lt.(UNEST*2.0)))) go to 5
         
         
C CHECK IF SAMPLE IS ALLREADY CONDITIONED 
C THIS IS ESSENTIAL,          
         if (sim(index).eq.UNEST) then
c            go to 5
         else 
            go to 5
         end if
      

c     USE SOMETHING LIKE NEXT LINE IF ONLY PART OF THE FIELD IS TO BE SIMULATED
c     +              (INDEX.gt.2460).or.(INDEX.lt.2400))) go to 5
c     If data are not assigned to grid node (sstrat=0), grid that is too close
c     to data will be skipped by (sim(index).lt.(UNEST*2.0)). Later it will
c     be reassigned by the very close grid node  
c     If data assigned to grid node (sstrat=1), grid node that has been 
c     a positive value will be the grid node that has received the sample
c     valeu or a grid node that has been visited. 
         
c                  write(ldbg,*) nxy, nx 
                  iz = int((index-1)/nxy) + 1
                  iy = int((index-(iz-1)*nxy-1)/nx) + 1
                  ix = index - (iz-1)*nxy - (iy-1)*nx
                  xx = xmn + real(ix-1)*xsiz
                  yy = ymn + real(iy-1)*ysiz
                  zz = zmn + real(iz-1)*zsiz
                  
                  if (idbg.ge.4) then
                     write(ldbg,*) 'index',iz, iy, ix
                     write(ldbg,*) '     ',zz, yy, xx
                     write(*,*) 'index',ix, iy, iz
                     write(*,*) '     ',xx, yy, zz
                  endif
                  
c     
c     Now, we'll simulate the point ix,iy,iz.  First, get the close data
c     and make sure that there are enough to actually simulate a value,
c     we'll only keep the closest "ndmax" data, and look for previously
c     simulated grid nodes:
c     
                  if(sstrat.eq.0) then
c     write(ldbg,*) 'call srchsupr'
                     call srchsupr(xx,yy,zz,radsqd,isrot,MAXROT,
     +                    rotmat,nsbtosr,ixsbtosr,iysbtosr,
     +                    izsbtosr,noct,nd,x,y,z,wt,nisb,nxsup,
     +                    xmnsup,xsizsup,nysup,ymnsup,ysizsup,
     +                    nzsup,zmnsup,zsizsup,nclose,close,
     +                    infoct)
                     if (idbg.ge.3) then
                        WRITE(ldbg, *) 'There are nclose=',nclose,
     +                       ' in the search radius',
     +                       ' for grid ', index
                     end if 

                     if(nclose.lt.ndmin) then
c     assign global mean and variance.
                        cmean = skgmean   
                        cstdev = sqrt(gvar)
                        go to 51
                     endif 
                     if(nclose.gt.ndmax) nclose = ndmax
                  endif

                  call srchnd(ix,iy,iz)

                  if (idbg.ge.0) then
                     WRITE(ldbg, *) 'There are ncnode=', ncnode,
     +                    ' in the search radius',
     +                    ' for grid ', in,index
                  end if


c
c     FIND DATA IN VOLUME NEIGHOURHOOD
c
c     

                  call nhoodvol(ix,iy,iz,xx,yy,zz,index)       
                  if (nusev.eq.0) then 
c                     write(*,*) 'nusev=',index,nusev
c                    stop
                  endif
                  if(read_volnh.eq.0) then      
                     write(97) (nusev)
                     write(97) (usev(i),i=1,nusev)
                     write(96) (ncnode)
                     write(96) (cnodex(i),i=1,ncnode)
                     write(96) (cnodey(i),i=1,ncnode)
                     write(96) (cnodez(i),i=1,ncnode)
                     write(96) (cnodev(i),i=1,ncnode)
                     write(96) (cnodeindex(i),i=1,xncnode)
                  endif	
                  if(read_volnh.eq.1) then      
                     read(97) nusev
                     read(97) (usev(i),i=1,nusev)
                     read(96) ncnode
                     read(96) (cnodex(i),i=1,ncnode)
                     read(96) (cnodey(i),i=1,ncnode)
                     read(96) (cnodez(i),i=1,ncnode)
                     read(96) (cnodev(i),i=1,ncnode)
                     read(96) (cnodeindex(i),i=1,xncnode)
                  endif	

c     
c     Calculate the conditional mean and standard deviation.  This will be
c     done with kriging if there are enough data, otherwise, the global mean
c     and standard deviation will be used:
c    
                  if(ktype.eq.2) then
                     gmean = lvm(index)
                  else
                     gmean = skgmean
                  end if
                  
 51	    	  continue
                  
                  
c     double check for not enough data with search radius. 
                  
                  if((nclose+ncnode+nusev).lt.1) then
    	             if (idbg.gt.-2) then
            WRITE(ldbg,*) ' __WARNING: neighboring data points and',
     +                    ' grid node have not been found.', 
     +                    ' Global mean and variance is assigned.'
            WRITE(*,*) ' __WARNING: neighboring data points and',
     +                    ' grid node have not been found.', 
     +                    ' Global mean and variance is assigned.'
            WRITE(*,*)    'index,nusev=',index,nusev
		     endif 
                     cmean  = gmean 
                     cstdev = sqrt(gvar)
                  else
                  
                     if (idbg.ge.3) then
                        WRITE(ldbg,*) 'cmean=', cmean, 'cstdev=', cstdev   
                     end if
                     
                     
c     
c     Perform the kriging.  Note that if there are fewer than four data 
c     in the case of ordinary kriging, then simple kriging is prefered so
c     that the variance of the realization does not become artificially
c     inflated:
c     
                     
c                     write(*,*) 'in=',in,' index=',index
                     lktype = ktype
                     if(ktype.eq.1.and.(nclose+ncnode).lt.4)lktype=0

                     do_partition=0
                        
                     if (do_partition.eq.1) then 


                        gvar_org=gvar
                        gmean_org=gmean
                        cbb_org=cbb


                        write(*,*) 'gmean=',gmean
     1                      ,' sqrt(gvar)=',sqrt(gvar)
                        
                        do j=1,2
                           nusev=1
                           usev(1)=j
c     write(*,*) 'gmean=',gmean,' sqrt(gvar)=',sqrt(gvar)
                           call krige_volume(ix,iy,iz,xx,yy,zz,lktype,
     +                          gmean,cmean,cstdev,index)
                           
                           write(*,*) 'cmean=',cmean,' cstdev=',cstdev
                           gmean=cmean
                           gvar=cstdev*cstdev
                           cbb=gvar
c     write(*,*) '--'
                        enddo
                     
                        gmean=gmean_org
                        gvar=gvar_org
                        cbb=cbb_org
                        

                     else
                        call krige_volume(ix,iy,iz,xx,yy,zz,lktype,
     +                       gmean,cmean,cstdev,index)
                     
c                        write(*,*) 'cmean=',cmean,' cstdev=',cstdev

                     endif


                  endif
                  






c
c TO CHECK THAT THE KRIGED MEAN SURFACE IS COORECT SET THE STANDARD DEV=0 
c      cstdev=0

                  

                  if (idbg.gt.3) then
                     WRITE(*,*) 'SIM in=',in,' RESULT index=',
     +                 order(in),' cmean=', 
     +                    cmean, ' cstdev=', cstdev
c                     stop
                  endif

c                  write(*,*) 'ncnode=',ncnode 
c                  write(*,*) 'nclose=',nclose 

c     
c     Draw a value from the uniform distribution having conditional mean and
c     variance and assign a value to this node:
c     

c DRAW A RANDOM SAMPLE FROM THE CHOSEN DISTRBUTION                  


c                  write(*,*)'',cmean,cstdev
                  p = acorni(idum)   	
                  if (p .ge. pkr) then 
                     if (doestimation.eq.0) then
cc                        if (cmean.lt.0) then
c HERE WE HAVE A BUG :::::                           
cc                           sim(index) = -1*simu(-1*cmean,cstdev)
cc                           write(*,*) 'neg ',cmean,sim(index)
cc                        else
                       sim(index) = simu(cmean,cstdev)                           write(*,*) 'pos ',cmean,sim(index)
cc                   endif

                   endif

      	           if(sim(index).lt.zmin) then
c	           	write(*,*) 'ZMIN VIOLATION',zmin,sim(index)
	           endif
	           if(sim(index).gt.zmax) then
c	           	write(*,*) 'ZMAX VIOLATION',zmax,sim(index)
	           endif
 
                     
                     
                     sim_mean(index) = cmean
                     sim_std(index) = cstdev                         
                  else
                     write(*,*) 'PKR PKR',pkr
                     sim(index) = cmean
                  end if
c                  write(*,*)'',in,sim_mean(index),
c     1                 sim_std(index),sim(index),p
c                  write(*,*)''
                  
                  if ((idbg.ge.14).AND.(in.eq.2)) then
                     stop
                  endif 
                  
                  
 111              format(1x, 6(f10.5, 1x))
 141              format(' random number ',f6.4,' realization ',f7.4)
c     
c     
                  
c     
c     END MAIN LOOP OVER NODES:
c     
 5                continue
                  
               end do
            

      
      if (doestimation.eq.1) then
         do i=1,nxyz
            sim(i)=sim_mean(i)
            write(lout_mean,87) sim_mean(i), sim_std(i)*sim_std(i)
 87         format(f19.8,f19.8)  
         enddo
      endif

c write estimated volume average to screen
      	if (idbg.gt.1) then
      	if ((icond.eq.1).OR.(icond.eq.3)) then
               write(*,89)               
               write(*,*) 'VOLUME AVERAGE ESTIMATES : '
               sumderr=0
               sumerr=0
               do ivol=1,nvol
                  vobs=0;
                  do id=1,ndatainvol(ivol)
                     call getindx(nx,xmn,xsiz,volx(ivol,id),ix1,testind)
                     call getindx(ny,ymn,ysiz,voly(ivol,id),iy1,testind)
                     call getindx(nz,zmn,zsiz,volz(ivol,id),iz1,testind)
                     ind = ix1 + (iy1-1)*nx + (iz1-1)*nxy
                     vobs=vobs+voll(ivol,id)*sim(ind)
                  enddo
c                  write (*,*) 'ivol=',ivol,vobs,volobs(ivol)
                  derr=100*(volobs(ivol)-vobs)/(volobs(ivol))
                  sumderr=sumderr+abs(derr)
                  sumerr=sumerr+abs((volobs(ivol)-vobs))
                  write(*,88) ivol,vobs,volobs(ivol),derr
 88               format(' Volume ',i3,': obs_sim=',f8.3,
     +              ' obs_vol=',f8.3,
     +              ' diff=',f8.3,'%')
                  

               enddo

               sumderr=sumderr/nvol
               sumerr=sumerr/nvol
               if (idbg.gt.0) write(*,89) sumderr,100*sumerr/gmean
 89            format(' Mean Error ',f5.3,': MeanRelErr=',f5.3,'%')

	endif
        endif
   
               if (idbg.gt.2)  then
                  print*, 'negative is ', neg, ', nsmall0 is ', 
     1                 nsmall0, ', small is ', nsmall, ', 
     2                 nlarge is ', nlarge
               endif
c     
c     In the case when no data assigned to grid, the grid node that is too
c     close to the data location will be reassigned the sample data value. 
c     
               if(sstrat.eq.0) then
                  do id=1,nd
                     call getindx(nx,xmn,xsiz,x(id),ix,testind)
                     call getindx(ny,ymn,ysiz,y(id),iy,testind)
                     call getindx(nz,zmn,zsiz,z(id),iz,testind)
                     xx  = xmn + real(ix-1)*xsiz
                     yy  = ymn + real(iy-1)*ysiz
                     zz  = zmn + real(iz-1)*zsiz
                     ind = ix + (iy-1)*nx + (iz-1)*nxy
                     test=abs(xx-x(id))+abs(yy-y(id))+abs(zz-z(id))
                     if(test.le.TINY) sim(ind) = vr(id)
                  end do
               end if
c     
c     Write results:
c     
               ne = 0
               av = 0.0
               ss = 0.0
               do ind=1,nxyz
                  simval = sim(ind)
                  ne = ne + 1
                  av = av + simval
                  ss = ss + simval*simval
c		  write(ldbg, *) simval 
                  write(lout,'(f16.8)') simval
               end do
               av = av / max(real(ne),1.0)
               ss =(ss / max(real(ne),1.0)) - av * av
               if (idbg.gt.-2)  then 
                 write(ldbg,112) isim,ne,av,ss
                 write(*,   112) isim,ne,av,ss
 112             format(/,' Realization ',i3,': number   = ',i8,/,
     +              '                  mean     = ',f12.4,
     +              ' (close to global mean)',/,
     +              '                  variance = ',f12.4,
     +              ' (close to global variance)',/)
               endif
c     
c     END MAIN LOOP OVER SIMULATIONS:
c     
               
               
c     
c     Return to the main program:
c     
               return
               end
