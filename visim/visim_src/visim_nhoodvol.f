      subroutine nhoodvol(ix,iy,iz,xx,yy,zz,sim_index)
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
c               SELECT NEIGHBORHOOD FOR VOLUMES
c               *******************************
c
c INPUT VARIABLES:
c
c   ix,iy,iz        index of the point currently being simulated
c   xx,yy,zz        location of the point currently being simulated
c   sim_index       index of point being simulated
c
c   nusevols [integer] : Use a maximum of 'nusevols' (on when musevols=2)
c
c   musevols=
c     [0] : use all  volumes
c     [1] : use only volumes sensitive to the current point, with a 
c           Cov(Point,Vol)/gvar>accept_frac 
c     [2] Use MAX      N data (sort by Cov(PointToVol)
c     [3] Use EXACTLY  N data (sort by Cov(PointToVol)
c
c
c OUTPUT VARIABLES:
c   nclosevol
c
c
c
c ORIGINAL: Thomas Mejer Hansen, Yongshe Liu  DATE: June, 2004
c Update to account for correlated data errors : TMH, 06/2007.
c-----------------------------------------------------------------------
      include 'visim.inc'
      integer volindex
      integer sim_index
      integer vol
      integer nsensvol,sensvol(MAXVOLS),volok(MAXVOLS)
      integer temp(MAXVOLS)
      integer temp2(MAXVOLS)
      real covvol(MAXVOLS)
      integer idata,nvolok
      integer nclosevol
      real covsum
      integer ivol1,ivol2,inhood,i,j
      integer nusevols_temp
      integer useCd

      nusevols_temp=nusevols

c      write(*,*) 'musevols=',musevols
c      write(*,*) 'densitypr=',densitypr

      if (idbg.gt.10) then 
         write(*,*) 'VOLNHOOD : musevols=',musevols,
     +        ' nusevols=',nusevols
      endif

c     musevol=0, USE ALL AVAILABLE DATA ALL THE TIME
      if (musevols.eq.0) then
         nusev=nvol
         do ivol=1,nvol
            usev(ivol)=ivol
         enddo
         return
      endif

      if (musevols.ge.1) then
         nusev=0;
         if (densitypr.gt.0) then
c     IF random path is NOT 'independant' we can simply look
c     for volume data that contain the current point
c     use only volume data through simulation pount
            do ivol=1,nvol
               do idata=1,ndatainvol(ivol)
                  volindex=voli(ivol,idata)
                  if (volindex.eq.sim_index) then
                     nusev=nusev+1;
                     usev(nusev)=ivol
c                     write(*,*) '',nusev,volindex,sim_index
                  endif
               enddo
            enddo
         else
c     USE ALL RAY DATA WITH A SIGNIFICANT CORRELATION
            
            do ivol=1,nvol
               call cov_data2vol(sim_index,xx,yy,zz,ivol,cov)
c               write(*,*) 'ivol=',ivol,' cov=',cov,gvar,cov/gvar
               if (cov.ge.(accept_fract*gvar)) then
c                  write(*,*) 'USE'
                  nusev=nusev+1;
                  usev(nusev)=ivol
               endif
               
            enddo

         endif
      else 
c     use all volume data all the time         
         nusev=nvol
         do i=1,nusev
            usev(i)=i
         enddo
      endif
      
c      write(*,*) 'A nusev=',nusev
c      stop

c      do ivol=1,nusev
c         write(*,*) 'A Using volume ',usev(ivol)
c      enddo
           
c     
c     CALCULATE THE COVARIANCE BETWEEN THE POINY TO BE SIMULATED AND
c     ALL THE VOLUME AVERAGES. THEN CHOOSE VOLUME AVERAGES 
c     ABOVE SOME THRESHOLD. 
c     ONLY DO THIS IF WE ARE ACTUALLY AT A LOCATION
c     WHERE A VOLUME AVRE IS PASSING THROUGH
c     
      if ((musevols.ge.2).AND.(nusev.gt.0)) then
         nusev=0;
         do ivol=1,nvol
            covsum=0
            call cov_data2vol(sim_index,xx,yy,zz,ivol,covsum)
            temp(ivol)=ivol
            temp2(ivol)=ivol
            covvol(ivol)=-covsum            
         enddo

c         do i=1,nvol
c            write(*,*), i,covvol(i),temp(i)
c         enddo

c     SORT BY cov(point,vol)
         call sortem(1,nvol,covvol,1,temp,c,d,e,f,g,h)
         
c         do i=1,nvol
c            write(*,*), i,covvol(i),temp(i)
c         enddo

         if (nvol.le.nusevols) then
            nusevols_temp=nvol
         else
            nusevols_temp=nusevols
         endif

         nusev=0
         if (musevols.eq.2) then
            do ivol=1,nusevols_temp
               if (abs(covvol(ivol)).gt.(accept_fract*gvar)) then
                  nusev=nusev+1;
                  usev(nusev)=temp(ivol)
               endif               
            enddo
         else
            do ivol=1,nusevols_temp
               nusev=nusev+1;
               usev(nusev)=temp(ivol)
            enddo
         endif
      endif


c     
c     make sure that simulated volumes are not used as volumes data
c     volok is an array of size [1:nusevol] indicating whether a 
c     volume has allready been been fully simulated. In that
c     case it shoul be excluded to avoid a singular kriging system
c     
c     This should be optimized using a lookup table for allreasy simulated 
c     volumes -> No need to run through the volume once it has been established
c     that is IS allready simulated completely
c     
      nvolok=0;
      do ivol=1,nusev
         volok(ivol)=0;
         do idata=1,ndatainvol(usev(ivol))
            volindex=voli(usev(ivol),idata)
            if (sim(volindex).le.UNEST) then
               volok(ivol)=1
            endif  
         enddo
         if (volok(ivol).eq.1) then
            nvolok=nvolok+1;
         endif
      enddo
      
      if (nvolok.ne.nusev) then 
          do ivol=1,nusev
c            if ((volok(ivol).eq.0).AND.(idbg.gt.3)) then
c               write(*,*) 'Volume ',usev(ivol),' is allready done'
c            endif
         enddo
      endif

c     FINALLY GO THROUGH THE VOLUMES AND DESELECT THE VOLUMES ALLREADY
c     SIMULATED AS INDICATED BY volok(ivol)=0

      if (nvolok.ne.nusev) then 
         i=0
         do ivol=1,nusev
            if (volok(ivol).eq.1) then
               i=i+1;
               usev(i)=usev(ivol)
            else
            endif
         enddo
         nusev=i
      endif



c
c NOW THE VOLUME AVERAGE DATA TO USE HAS BEEN FOUND ('usev' and 'nusev')
c


c
c     SELECT WHICH PREVIOSULY SIMULATED OR HARD DATA WITHIN VOLUME 
c     TO USE AS CONDITIONAL DATA
c


c      write(*,*) 'Number of cond points before considering ray:',ncnode

c     FIRST FIND THE VOLUMES SENSITIVE TO THE SIMULATED POINT
      nsensvol=0;
      do ivol=1,nusev
         do idata=1,ndatainvol(usev(ivol))
            if (voli(usev(ivol),idata).eq.sim_index) then 
c     USE ALL PREVIOUSLY SIMULATED DATA ON RAY
               nsensvol=nsensvol+1
               sensvol(nsensvol)=ivol
               
            endif
         enddo
      enddo
      
c      write(*,*) 'Number of vols sensitive to sim point',nsensvol
c      write(*,*) 'Number of USEV',nusev
c      stop

c      if (nsensvol.gt.0) then
c         do i=1,nsensvol
c            write(*,*) sim_index,' SENSITIVE TO VOLUME ',
c     +           usev(sensvol(i)),nsensvol
c         enddo
c      endif

      useCd=1

      if (musevols.ge.4) then

c     CONSIDER THE DATACOVARIANCE !!
c      write(*,*) 'nusev=',nusev
      do i=1,nusev
c         write(*,*) 'CHECKING FOR CORRELATED DATA COV,',
c     +        usev(i)
         do ivol=1,nvol

            if (datacov(ivol,usev(i)).gt.0) then
c               write(*,*) 'NVOL=',nvol
c               write(*,*) 'CHECKING ivol=',ivol,' corr to ',
c     +              usev(i),datacov(ivol,usev(i))
c     CHECK IF VOLUME DATA IS ALLREADY IN VOLHOOD
               inhood=0
c               write(*,*) nvol
               do j=1,nvol 
c                  if (inhood.eq.0) then
c                     write(*,*) 'CD :usev(j)=',j,usev(j),ivol
c                  endif
                  if (usev(j).eq.ivol) then
c                     write(*,*) 'ivol=',ivol,'  inhood' 
                     inhood=1
                  endif
               enddo

c               write(*,*) 'inhood',inhood
                              
               if (inhood.eq.0) then
                  nusev=nusev+1;
                  usev(nusev)=ivol
c                  write(*,*) 'nusev=',nusev
c                  write(*,*) 'ivol=',ivol
c                  write(*,*) 'DATAOCV=',datacov(ivol,usev(sensvol(i)))
c                  stop
               endif
            endif

         enddo
      
      enddo
c      write(*,*) 'nusev2=',nusev
      endif 



c      do i=1,nusev
c         write(*,*) 'i=',i,' usev=',usev(i)
c      enddo
c      stop

      
c
c     LOOP THORUGH SENSITIVE VOLUMES AND FIND DATA TO ADD 
c     TO THE SEARCH NEIGHBORHOOD
c 
      nclosevol=0
      do isensvol=1,nsensvol
         ivol=usev(sensvol(isensvol))
         do idata=1,ndatainvol(ivol)
c            write(*,*) 'VOLUME=',ivol,'ray index=',voli(ivol,idata)
            if (sim(voli(ivol,idata)).ne.UNEST) then
               
c     CHECK THAT THE DATA HAS NOOT ALLREADY BEEN INCLUDED IN THE NEIGHBORHOOD
               dinnhood=0
               do i=1,ncnode
c                  write(*,*) 'i=',i,'/',ncnode
c                  write (*,*) 'ncnode,i,icnode=',ncnode,i,icnode(i)
                  if (cnodeindex(i).eq.voli(ivol,idata)) then
                     dinnhood=1
c                     write (*,*) 'DATA IS ALLREADY IN NHOOD',
c     +                    icnode(i),cnodeindex(i),' ivol=',ivol,
c     +                    ' ncnode=',ncnode,' i=',i
c     stop                                      
                  endif
               enddo
c               write (*,*) 'dinnhood=',dinnhood
  
c     NOW ADD THE DATA TO THE PREV COND DATA IF 
c     IT IS NOT ALLREADY ADDED
               if ((dinnhood.eq.0).AND.(ncnode.lt.MAXNOD)) then

                  nclosevol=nclosevol+1
                  ncnode = ncnode +1 

                  cnodex(ncnode) = volx(ivol,idata)
                  cnodey(ncnode) = voly(ivol,idata)
                  cnodez(ncnode) = volz(ivol,idata)
                  cnodev(ncnode) = sim(voli(ivol,idata))
                  cnodeindex(ncnode) = voli(ivol,idata)
                  
c                  write(*,*) 'ADDING DATA TO NEIGHBORHOOD',ncnode

                  if (ncnode.eq.(MAXNOD)) then
                     write(*,*) 'YOU REACHED MAX NUMBER OF NODES - ',
     +                    'ncnode=',ncnode,' MAXNOD=',MAXNOD
                     write(*,*) 'Recompile or rewrite :)';
                  endif
                  

               else
c                  write (*,*) 'DATA ALLREADY IN NHOOD'
               endif

               
            else
c               write(*,*) 'POINT IN RAY IS NOT YET SIMULATED '
            endif
         enddo
      enddo

c      if (nclosevol.gt.0) then
c         write (*,*) 'nclosevol=',nclosevol
c      endif 


      


      return

      
      end
