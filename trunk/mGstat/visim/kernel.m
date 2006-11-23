% kernel : computes the sensitivity kernel for a wave traveling from S to R.
%
% CALL : 
%    [K,RAY,timeS,timeR,raypath,raylength]=kernel(Vel,x,y,z,S,R,T,alpha);
%
% IN : 
%    Vel : Velocity field
%    x [1:nx] :
%    y [1:ny] :
%    z [1:nz] :
%    S [1,3] : Location of Source
%    R [1,3] : Location of Receiver
%    T    : Dominant period
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
function [K,RAY,tS,tR,raypath,raylength]=kernel(Vel,x,y,z,S,R,T,alpha,x0,y0,z0,dx,doPlot);

  if nargin<7, freq=7.7; end
  if nargin<8, alpha=1; end

    x0=1;
    y0=1;
    z0=1;
  
  if nargin<13
    doPlot=0;
  end
  
  tS=fast_fd_2d(x,y,Vel,S);
  tR=fast_fd_2d(x,y,Vel,R);

  dt=tS+tR;dt=dt-min(dt(:));

  dx=x(2)-x(1);
  dy=y(1)-y(1);
  d1=(dx+dy)/2;
  aS=tS;aS(find(aS==0))=d1;
  aR=tR;aR(find(aR==0))=d1;

  % spread_type=0; % PLANE
  spread_type=1; % CYLINDRICAL
  % spread_type=2; % SPHERICAL

  aR=spherical_spreading(aR,spread_type);
  aS=spherical_spreading(aS,spread_type);

  K=munk_fresnel_2d(T,dt,alpha,aS,aR);


  % NOW FIND FIRST ARRIVAL AND RAYLENGTH  
  str_options = [.1 1000];
  [xx,yy]=meshgrid(x,y);
  [U,V]=gradient(tS);
  start_point=R;
  raypath = stream2(xx,yy,-U,-V,start_point(1),start_point(2),str_options);
  
  raypath=raypath{1};
  
  % GET RID OF DATA CLOSE TO SOURCE (DIST <DX)
  r2=raypath;r2(:,1)=r2(:,1)-S(1);r2(:,2)=r2(:,2)-S(2);
  distS=sqrt(r2(:,1).^2+r2(:,2).^2);  
  ClosePoints=find(distS<dx/10);
  %igood=find(distS>dx/10);  
  if isempty(ClosePoints)    
    igood=1:1:length(distS);
  else
    igood=1:1:ClosePoints(1);
  end
  raypath=[raypath(igood,:);S(1:2)];

  raylength=sum(sqrt(diff(raypath(:,1)).^2+diff(raypath(:,2)).^2));
  
  ix=ceil((raypath(:,1)-(x0-dx/2))./dx);
  iy=ceil((raypath(:,2)-(y0-dx/2))./dx);

  ix(find(ix<1))=1;
  iy(find(iy<1))=1;

  
  
  RAY=K.*0;
  for j=1:length(ix)
    RAY(iy(j),ix(j))=RAY(iy(j),ix(j))+1;
  end
  
  % NORMALIZE K
  K=raylength.*K./sum(K(:));

  %doPlot=0;
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

  