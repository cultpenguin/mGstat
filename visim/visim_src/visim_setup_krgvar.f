      subroutine setup_krgvar
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
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c    								    c	
c								    c	
c          Set up the Kriging Variance Matrix 
c          ***********************************
c 
c If conditional simulation is made and the kriging variance 
c matrix is calculated in stead of being read from a user specified 
c file(localfl), then the kriging variance matrix is set up for future
c use in trans. 
c
c inovar:  number of grid node that can not be reached by kriging
c          radius search
c zmaxvar: max kriging variance that can be obtained.
c novar(): location index for those grid node that can not be reached.
c
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      use geostat_allocate
	  include  'visim.inc'

      real*8   acorni
      logical testind

c
c The variogram model specified in the parameter file is used for
c simulation. The radius for search of neighboring data points is usually
c small in the case of because both sample data and previously simulated 
c nodes are available for conditioning. However we need a larger radius to do
c kriging search to set up the kriging variance matrix if needed.  Hence
c in calculating the kriging variance for use in trans, we will
c increase the radius by 1.5. This will decrease the possibility that
c remote unknown location is not reached by the kriging search.   
c 

      radsqd = radsqd * 1.5 * 1.5


c   
c Set up the rotation/anisotropy matrices that are needed for the
c variogram and search.
c

      write(*,*) 'Setting up kriging variance'
	
                  
      write(ldbg,*) 'Setting up rotation matrices',
     +              ' for variogram and search'
      do is=1,nst(1)
            call setrot(ang1(is),ang2(is),ang3(is),anis1(is),anis2(is),
     +                  is,MAXROT,rotmat)
      end do
      isrot = MAXNST + 1
      call setrot(sang1,sang2,sang3,sanis1,sanis2,isrot,MAXROT,rotmat)  

c
c Set up the super block search:
c
      
      if(sstrat.eq.0) then
            write(ldbg,*) 'Setting up super block search strategy'
            nsec = 1
            call setsupr(nx,xmn,xsiz,ny,ymn,ysiz,nz,zmn,zsiz,nd,x,y,z,
     +                   vr,wt,nsec,sec,sec2,sec3,MAXSBX,MAXSBY,MAXSBZ,
     +                   nisb,nxsup,xmnsup,xsizsup,nysup,ymnsup,ysizsup,
     +                   nzsup,zmnsup,zsizsup)
            call picksup(nxsup,xsizsup,nysup,ysizsup,nzsup,zsizsup,
     +                   isrot,MAXROT,rotmat,radsqd,nsbtosr,ixsbtosr,
     +                   iysbtosr,izsbtosr)
      end if

c
c Set up the covariance table and the spiral search:
c
      call ctable

c
c Initialize the grid:
c
            do ind=1,nxyz
                  sim(ind) = UNEST
            end do


c 
c Assign sample data to the closest grid node if it is specified:
c

            TINY = 0.0001

            do id=1,nd
                  call getindx(nx,xmn,xsiz,x(id),ix,testind)
                  call getindx(ny,ymn,ysiz,y(id),iy,testind)
                  call getindx(nz,zmn,zsiz,z(id),iz,testind)
                  ind = ix + (iy-1)*nx + (iz-1)*nxy
                  xx  = xmn + real(ix-1)*xsiz
                  yy  = ymn + real(iy-1)*ysiz   
                  zz  = zmn + real(iz-1)*zsiz
                  test = abs(xx-x(id)) + abs(yy-y(id)) + abs(zz-z(id))

c
c Assign this sample data to the nearest node unless there is a closer
c sample data:
c 
            
                  if(sstrat.eq.1) then
                        if(sim(ind).ge.0.0) then
                              id2 = int(sim(ind)+0.5)
                              test2 = abs(xx-x(id2)) + abs(yy-y(id2))
     +                                               + abs(zz-z(id2))
                              if(test.le.test2) sim(ind) = real(id)
                              write(ldbg,102) id,id2
                        else
                              sim(ind) = real(id)
                        end if
                  end if

c
c In the case of not assigning data to nearest grid node, if it
c is too close to a grid node (<TINY) then assign flag with very negative
c value. The kriging variance at this node will be 0    
c
                  if(sstrat.eq.0.and.test.le.TINY) sim(ind)=10.0*UNEST
            end do
c
c          finish the loop over all the sample data
c


 102        format(' WARNING data values ',2i5,' are both assigned to ',
     +           /,'         the same node - taking the closest')

c
c Now, enter data values into the grid:
c

            do ind=1,nxyz
                  id = int(sim(ind)+0.5)
                  if(id.gt.0) sim(ind) = vr(id)
c
c If the case when no data are assgned to grid node, then nclose = 0.    
c

            end do
            irepo = max(1,min((nxyz/10),10000))

c
c MAIN LOOP OVER ALL THE NODES TO GET THE KRIGING VARIANCE:
c
c
c In this part of the code, each grid node is accessed by its spatial
c order without any random path. At each grid node, the kriging variance 
c is calculated.  If no data are assigned to the grid node, the kriging
c variance will still be calculated but the result will be none zero
c unless the grid is very close to the sample data location (<TINY). If 
c data are assigned to the nearest location, then at that grid node
c location the kriging variance will be zero.  
c

            if (idbg.ge.3) then
	       write(ldbg, *) 'Sample data location and grid search'    
	    end if   


            inovar = 0
            zmaxvar = 0                        
            do in=1,nxyz
                  index = int(in+0.5)
	          if (idbg.ge.3) then 
                    WRITE(ldbg, *) 'SIM(', INDEX, ')=', SIM(INDEX)
		  end if 
c
c (sim(index).gt.(UNEST+EPSLON)) is satisfied when data are assigned to
c the nearest grid node as specified by sstrat=1 option. 
c (sim(index).lt.(UNEST*2.0)) is satisfied when data is too close to grid
c node in the case when data are not assign to the grid node(sstrat=0)
c

                  if(sim(index).gt.(UNEST+EPSLON).or.
     +               sim(index).lt.(UNEST*2.0)) then
                     krgvar(index) = 0.0 
                     go to 5
                  end if 
                  iz = int((index-1)/nxy) + 1  
                  iy = int((index-(iz-1)*nxy-1)/nx) + 1
                  ix = index - (iz-1)*nxy - (iy-1)*nx
                  xx = xmn + real(ix-1)*xsiz
                  yy = ymn + real(iy-1)*ysiz
                  zz = zmn + real(iz-1)*zsiz
            
c
c Now we will do the neighboring data location and grid node search. 
c In the case when data are not assigned to grid node (sstrat=0),
c srchsupr is only conducted to find the nearest sample data. 
c In the case when data are assigned to grid node (sstrat=1), 
c srchnd is conducted to find the nearest grid node data. 

                  if(sstrat.eq.0) then
                        call srchsupr(xx,yy,zz,radsqd,isrot,MAXROT,
     +                          rotmat,nsbtosr,ixsbtosr,iysbtosr,
     +                          izsbtosr,noct,nd,x,y,z,wt,nisb,nxsup,
     +                          xmnsup,xsizsup,nysup,ymnsup,ysizsup,
     +                          nzsup,zmnsup,zsizsup,nclose,close,
     +                          infoct)
                        WRITE(ldbg, *) 'There are nclose=', nclose, 
     +                                 ' in the search radius.'
                        WRITE(*, *) 'There are nclose=', nclose,
     +                                 ' in the search radius.'

c When there are less than 2 data within the search radius, the kriging
c system will not give a correct variance calculation. Instead, we assign
c the max variance value from those grid node where kriging variance can
c be calculated. 

                        if(nclose.lt.2) then
                           inovar = inovar + 1
                           novar(inovar) = in
                           go to 5
                        endif
                        if(nclose.gt.ndmax) nclose = ndmax
                     else
                        call srchnd(ix,iy,iz)
                        if(idbg.ge.3) then
                           WRITE(ldbg, *) 'There are ncnode=', ncnode,
     +                          ' in the search radius.'
                        end if
                        if(ncnode.lt.2) then
                           inovar = inovar + 1
                           novar(inovar) = in
                           go to 5
                        endif
                        if(ncnode.gt.nodmax) ncnode = nodmax 
                     end if 
                     
                  
                     if(ktype.eq.2) then
                        gmean = lvm(index)
                     else
                        gmean = skgmean   
                     end if
                     

                     
                     
c     
c     Perform the kriging.  Note that if there are fewer than four data
c     in the case of ordinary kriging, then simple kriging is prefered so that
c     the variance of the realization does not become artificially inflated:
c     
                     lktype = ktype 
                     if(ktype.eq.1.and.(nclose+ncnode).lt.4)lktype=0   
c     
c     global mean (skgmean) is still needed for OK when there are fewer than 4
c     data within the search radius
c     
                     call krige(ix,iy,iz,xx,yy,zz,lktype,
     +                    gmean,cmean,cstdev)

                     
                     krgvar(index) = cstdev * cstdev 
                     if (krgvar(index).ge.zmaxvar) zmaxvar=krgvar(index)                  
 5                   continue
                  end do 
c     
c     MAIN LOOP OVER ALL THE NODES TO GET THE KRIGING VARIANCE:
c     
c     
c     For those nodes that have not been visited, the previous max variance
c     will be assigned.
c 
                  
                  
                  do in=1, inovar
                     index= novar(in)
                     krgvar(index) = zmaxvar
                  end do
                  
                  if(idbg.ge.3) then 
                     write(*,*) 'The kriging variance at',
     +                    ' each grid node is', 
     +                    ' given as follows'
                  do itt=1, nxyz
                  write(ldbg,*) 'node index =', itt, 'kriging variace', 
     +               ' =', krgvar(itt) 
                  end do 
                  end if 
                  
                  radsqd = radsqd/1.5/1.5
                  
c     
c     At the end of kriging variance calculation, the radius is decreased back
c     to the original radius intended for simulation.
c     
                  return
                  end               
      
