      subroutine rayrandpath(order)
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
c  Descriptions:
c     We can define both random and sequential path for 1 ray using this subroutine
c     The random path are store in the array called 'order'.
c     The random value and random path are writen to a temporary output file for check. 
c
c  parameters:
c
c      densitypr : Density priority : Give higher priority (sample early) 
c                  to data points sensitive to larger volumes 
c                  [2] : order by number of volumes at data
c                  [1] : order by sum of density at data
c                  [0] : Dont use density priority
c
c      shuffvol: [1] randomly shuffle volumes
c                [0] use volumes in the order they are read
c      
c      shuffinvol : [0] sort by distance from source (AS READ)
c                   [1] shuffle within volume
c                   [2] shuffle withine all volumes 
c                       This means a) random point i any volume
c                             then b) random point outside volume
c                       This option overrides 'shuffvol'
c
c
c ORIGINAL: Yongshe Liu Thomas Mejer Hansen   DATE: June, 2004
c-----------------------------------------------------------------------
      
      include 'visim.inc'
      integer ind,ix,iy,iz,nxy,j,k,nvp
      real tempsim(MXYZ),vvx(MAXGEOMDATA)
      real simrest(MXYZ)
      real svoll(MXYZ),nvoll(MXYZ)
      integer vorder(MXYZ),ivoll(MXYZ)
      real svoll2(MXYZ),nvoll2(MXYZ)
c     NEXT LINE ONLY CHOSEN AS REEL TO AVOID DEBUG INFO (INT)c
      integer varr(MAXVOLS)
      real tempvol(MAXVOLS)
      real p
c      integer shuffvol,shuffinvol,densitypr
      character tmpfl*80

c
c these next variables COULD be set in visim.par file      
c but, since there is a clear benefit setting shiffinvol=2,
c this is chosen as default.
c The defaults are chosen here : 

      shuffvol=1;
      shuffinvol=2;
c      densitypr=2;
      
      if (idbg.gt.0) then
         write(*,*) 'Random Path : densitypr=',densitypr,
     +        '  shuffvol=',shuffvol,
     +        '  shuffinvol=',shuffinvol
      endif
      
      nxy=nx*ny;

c     Classic independant path
      if (densitypr.eq.0) then         
         p=real(acorni(idum))
         call sortem(1,nxyz,sim,1,order,c,d,e,f,g,h)
         return
      endif

      

c     SORT VOLUMES IF NEEDED
      if (shuffvol.eq.1) then
         do ivol=1,nvol
            tempvol(ivol) = real(acorni(idum))
            varr(ivol) = ivol

         enddo
         call sortem(1,nvol,tempvol,1,varr,c,d,e,f,g,h)
      else 
c     ELSE DONT SORT VOLUMES
         do ivol=1,nvol
            varr(ivol)=ivol
         enddo
      endif

      if (idbg.gt.3) then 
         do ivol=1,nvol
            write(*,*) 'varr(',ivol,')=',varr(ivol)
         enddo		  
      end if

c     INITIALIZE THE SORT OF ALL THE POINTS
c     ASSIGN A RANDOM VALUE BETWEEN 0 and 1 TO ALL DATA
      do i=1,nxyz
            tempsim(i)   = real(acorni(idum))
            order(i) = i
      enddo

c
c     the nvoll2 and svoll2 are only initialized since the sortem function
c     alters the values of nvoll and svoll when called !
c     

c     APPLY DENSITY PRIORITY IF NEEDED
      nvp=1
      if (densitypr.gt.1) then
c         write(*,*) 'Density Prioirity'
         do ind=1,nxyz
            svoll(nvp)=0;
            nvoll(nvp)=0;
            svoll2(nvp)=0;
            nvoll2(nvp)=0;
            do ivol=1,nvol
               do idata=1,ndatainvol(ivol)
                  if (voli(ivol,idata).eq.ind) then
                     svoll(nvp)=svoll(nvp)+voll(ivol,idata);
                     nvoll(nvp)=nvoll(nvp)+1
                     nvoll2(nvp)=nvoll(nvp)
                     svoll2(nvp)=svoll(nvp)
                     ivoll(nvp)=ind
                     vorder(nvp)=nvp;
                  end if
               end do
            end do
c     ONLY CONSIDER THIS DATA OF MORE THAN ONE VOLUME GOES THROUGH IT
            if (nvoll(nvp).gt.1) then 
               if (idbg.gt.-13) then 
c                  write(*,*) 'nv(',ind,')=',svoll(nvp),nvoll(nvp),nvp
               end if
               nvp=nvp+1
            end if
         end do         
         nvp=nvp-1
 
c         do i=1,20
c            write(*,*) 'ivp=',i,' vorder=',vorder(i),svoll(i),nvoll(i)
c         end do
 
c     NOW SORT THE nvp DATA USING EITHER OF TWO CRITERIA
         if (densitypr.eq.2) then 
C     SORT BY SUM OF DENSITY AT POINT
            if (idbg.gt.0) write(*,*) 'SORT BY DENSITY'
            call sortem(1,nvp,svoll,1,vorder,c,d,e,f,g,h)
         else
C     SORT BY NUMBER VOLUME DATA POINT
            if (idbg.gt.0) write(*,*) 'SORT BY MVOLS THROUGH POINT'
            call sortem(1,nvp,nvoll,1,vorder,c,d,e,f,g,h)
         end if
         

c         do i=1,20
c            j=vorder(i)
c            write(*,*) 'i=',i,' j=',j,' ',svoll(j),svoll2(j)
c            write(*,*) 'i=',i,' j=',j,' ',nvoll(j),nvoll2(j)
c         end do


         do i=1,nvp
            if (densitypr.eq.2) then 
               tempsim(ivoll(vorder(i))) = tempsim(ivoll(vorder(i))) - 
     +              (nvol + real(i)/10000 + svoll2(vorder(i)) )
            else
               tempsim(ivoll(vorder(i))) = tempsim(ivoll(vorder(i))) - 
     +              (nvol + real(i)/10000 + nvoll2(vorder(i)) )
            end if 
c            write(*,*) 'ivp=',i,' vorder=',vorder(i),svoll2(i),nvoll2(i),
         end do
         


      end if
   
   
c     GET INDEX OF DATA IN VOLUME
      i=0
      do ivol=1,nvol
         do idata=1,ndatainvol(varr(ivol))
            i=i+1;
            call getindx(nx,xmn,xsiz,volx(varr(ivol),idata),ix,testind)
            call getindx(ny,ymn,ysiz,voly(varr(ivol),idata),iy,testind)
            call getindx(nz,zmn,zsiz,volz(varr(ivol),idata),iz,testind)
            ind = ix + (iy-1)*nx + (iz-1)*nxy
c     ONLY CHANGE THE TEMPSIM FOR THE INDEX IF NOT PREVIOUSLY SAMPLED
            if (tempsim(ind).gt.0) then              
               if (shuffinvol.eq.0) then
                  tempsim(ind)   = real(idata)/10000 - (nvol - ivol +1)
               elseif (shuffinvol.eq.1) then
                  tempsim(ind)   = tempsim(ind) - (nvol - ivol +1 )
               elseif (shuffinvol.eq.2) then
                  tempsim(ind)   = tempsim(ind) - 1
               end if 
c               write(*,*) 'ind,tempsim : ',ind,tempsim(ind),nvol,ivol
            else
c     DO NOTHING
            endif
         end do
      end do


c SORT THE DATA 
      call sortem(1,nxyz,tempsim,1,order,c,d,e,f,g,h)
      
   
cc     WRITE THE RANDOM PATH TO DISK 
c               if (idbg.gt.-2) then
c                 write(tmpfl,871) 'randpath',outfl
c                 open(9, file=tmpfl, status = 'unknown')
c         	
c                 do ind=1,nxyz
c                   write(9,*) ind ,sim(ind), order(ind)
c                 end do
c                 close(9)
c         
c               endif   
c   
c871           format(A,'_',A)

      return
      end
