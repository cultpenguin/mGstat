% kernel_multiple : computes the sensitivity kernel for a wave traveling from S to R.
%
% CALL : 
%    [K,RAY,Gk,Gray,timeS,timeR,raypath]=kernel_multiple(Vel,x,y,z,S,R,T,alpha);
%
% IN : 
%    Vel : Velocity field
%    x [1:nx] :
%    y [1:ny] :
%    z [1:nz] :
%    S [1,3] : Location of Source
%    R [1,3] : Location of Receiver
%    T : Donminant period
%    alpha: controls exponential decay away ray path
%
% OUT :
%    K : Sensitivity kernel
%    R : Ray sensitivity kernel (High Frequency approx)
%    timeS : travel computed form Source
%    timeR : travel computed form Receiver
%    raypath [nraydata,ndim] : the center of the raypath 
%
% See also : fast_fd_2d
%
% TMH/2006
%
function [K,RAY,Gk,Gray,tS,tR,raypath_mat,raylength_mat]=kernel_multiple(Vel,x,y,z,S,R,T,alpha,doPlot);

  if nargin<7, T=2.7; end
  if nargin<8, alpha=1; end
  if nargin<9, 
      doPlot=0;
  end
  x0=x(1);
  y0=y(1);
  z0=z(1);
  dx=x(2)-x(1);
  
  
  ns=size(S,1);
  
  dx=x(2)-x(1);
  dy=y(1)-y(1);
  d1=(dx+dy)/2;

  tS=fast_fd_2d(x,y,Vel,S);
  tR=fast_fd_2d(x,y,Vel,R);

  dt=tS+tR;
  K=zeros(size(dt));
  RAY=zeros(size(dt));
  str_options = [0.1 10000];
  [xx,yy]=meshgrid(x,y);
  for is=1:ns
    mt=min(min(dt(:,:,is)));
    dt(:,:,is)=dt(:,:,is)-mt;

    % GEOMETRICAL SPREADING
    aS=tS(:,:,is);aS(find(aS==0))=d1;
    aR=tR(:,:,is);aR(find(aR==0))=d1;
    % spread_type=0; % PLANE
    spread_type=1; % CYLINDRICAL
    % spread_type=2; % SPHERICAL
    aR=spherical_spreading(aR,spread_type);
    aS=spherical_spreading(aS,spread_type);


    % CALCULATE KERNEL
    %K(:,:,is)=munk_fresnel_2d(T,dt(:,:,is),alpha,aS,aR);
    K(:,:,is)=munk_fresnel_2d(T,dt(:,:,is),alpha);
    % K(:,:,is)=munk_fresnel_2d(freq,dt(:,:,is),alpha,1./tS(:,:,is),1./tR(:,:,is));

    % NOW FIND FIRST ARRIVAL AND RAYLENGTH  
    [U,V]=gradient(tS(:,:,is));
    start_point=R(is,:);
    raypath = stream2(xx,yy,-U,-V,start_point(1),start_point(2),str_options);
    
    raypath=raypath{1};
      
    % GET RID OF DATA CLOSE TO SOURCE (DIST<DX)
    r2=raypath;r2(:,1)=r2(:,1)-S(is,1);r2(:,2)=r2(:,2)-S(is,2);
    distS=sqrt(r2(:,1).^2+r2(:,2).^2);  
    ClosePoints=find(distS<dx/10);
    %ClosePoints=find(distS<dx/2);
    %igood=find(distS>dx/10);  
    if isempty(ClosePoints)    
      igood=1:1:length(distS);
    else
      igood=1:1:ClosePoints(1);
    end
    raypath=[raypath(igood,:);S(is,1:2)];
    raylength=sum(sqrt(diff(raypath(:,1)).^2+diff(raypath(:,2)).^2));
    
    raypath_mat{is}=raypath;
    raylength_mat(is)=raylength;
    
    ix=ceil((raypath(:,1)-(x0-dx/2))./dx);
    iy=ceil((raypath(:,2)-(y0-dx/2))./dx);
    
    ix(find(ix<1))=1;
    iy(find(iy<1))=1;
    
    
    for j=1:length(ix)
      RAY(iy(j),ix(j),is)=RAY(iy(j),ix(j),is)+1;
    end
    
    sk=K(:,:,is);sk=sum(sk(:));
    K(:,:,is)=raylength_mat(is).*K(:,:,is)./sk;
       
  end

  
  
  % REMOVE ALL SENSITIVITY BELOW sen; 
  sens=0.0001;
  K(find(K<sens))=0;
  
  % Horisontally normalization of Fresenel Kernel

  for is=1:ns
      single_ray=RAY(:,:,is);
      single_ray=single_ray./sum(single_ray(:));
      sRAY=sum(single_ray);

      
      for i=1:size(single_ray,2);
          sk=sum(K(:,i,is));
          if sk>0
              K(:,i,is)=sRAY(i).*K(:,i,is)./sk;
          end
      end
  end

  
  % REPORT 
  Gray=zeros(ns,length(x)*length(y));
  Gk=zeros(ns,length(x)*length(y));
  for is=1:ns
    g=RAY(:,:,is);
    g=g./sum(g(:));
    Gray(is,:)=g(:);

    gk=K(:,:,is);
    gk=gk./sum(gk(:));
    Gk(is,:)=gk(:);
  end
  
  
  if doPlot>0;    
    for i=1:ns;imagesc(dt(:,:,i));axis image;drawnow;end
    for i=1:ns;imagesc(K(:,:,i));axis image;drawnow;end
    for i=1:ns;imagesc(RAY(:,:,i));axis image;drawnow;end
  end
  return

  
  % OLD CODE
  if doPlot>0;
    figure(1);
    subplot(2,5,1)
    imagesc(x,y,Vel);axis image;title('Velocity model')
    subplot(2,5,2)
    imagesc(x,y,tS);axis image;title('t_{source}')
    subplot(2,5,3)
    imagesc(x,y,tR);axis image;title('t_{receiver}')

    subplot(2,5,4)    
    imagesc(x,y,K);axis image;title('Fresnel kernel')
    hold on
    plot(S(1),S(2),'r*')
    plot(R(1),R(2),'ro')
    plot(raypath(:,1),raypath(:,2),'w*','Markersize',2)

    %plot(x(ix),y(iy),'gx')
    %title(['l=',num2str(raylength)])
    hold off
    
    subplot(2,5,5)    
    imagesc(x,y,RAY);axis image
    hold on
    plot(S(1),S(2),'r*')
    plot(R(1),R(2),'ro')
    hold off
    title('Ray kernel')
    drawnow;

    if doPlot>1
    
      subplot(2,5,7)
      imagesc(x,y,tS+tR);axis image;title('t_{s+r}')
      
      subplot(2,5,8)
      imagesc(x,y,U);axis image;title('grad_U')
      subplot(2,5,9)
      imagesc(x,y,V);axis image;title('grad_V')
      drawnow
    end
      
  end

  