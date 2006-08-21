% visim_setup_tomo_kernel : Setup sensitivity kernel for VISIM tomography
% 
% CALL :
%    visim_setup_tomo_kernel(V,S,R,m_ref,t,t_err,name,ktype,doPlot);
%
% V: VISIM matlab structure
% S: [Nvol,2] list of sources for each volume
% R: [Nvol,2] list of Receivers for each volume
% t: [Nvol,1] List of observed travel times for each volume
% t_err: [Nvol,1] List of observed travel times measurement errors
% name: [string] name to append to VISIM geomtery files
% ktype [int]  [1] High Freq Approx (rays) [2] Fresnel zone sensitivity 
% doPlot : [0] No plotting [1] some plotting [2] most plotting.
%
% See also : kernel, fast_fd_2d, munk_fresnel_2d
%
% TMH/2006
%
function [V,G,Gray,rl]=visim_setup_tomo_kernel(V,S,R,m_ref,t,t_err,name,ktype,doPlot);
    
  if nargin==0
    V=read_visim('sgsim_cond_2.par');
  end
  
  if nargin<7
    name='';
  end
  
  if nargin<8
    ktype=1; % RAY
    % ktype=2; FRESNEL
  end
  
  if nargin<2
    
    r=load('radar.txt');
    t=r(:,5);
    t_err=r(:,6);
    
    r(:,1:4)=r(:,1:4).*.25;
    
    S=[r(:,1) r(:,2)];
    R=[r(:,3) r(:,4)];
  end

  
  if nargin<4
    
    m_ref=read_eas('visim_sgsim_refmod.eas');
    x_ref=m_ref(:,1);
    z_ref=m_ref(:,2);
    m_ref=m_ref(:,3);
    
    m=mean(m_ref);
    
    %m_ref=reshape(m_ref,49,21)';
    m_ref=reshape(m_ref,49,21)';
    %m_ref=m_ref.*0+.13,
    
    %load SR
  end

  if isempty(t)
    t=ones(size(S,1));
    t_err=ones(size(S,1));
  end
  
  if exist('doPlot')==0
    doPlot=0;
  end
  
  
  G=zeros(size(S,1),length(m_ref(:)));
  Gray=G;
  
  freq=8;
  alpha=1.5;
  
  
  [Kmat,Raymat,G,Gray,tS,tR,raypath,rl]=kernel_multiple(m_ref',V.x,V.y,V.z,[S],[R],freq,alpha,V.xmn,V.ymn,V.zmn,V.xsiz,doPlot); 
  
  %% MAY BE BAD...
  % ZERO ALL ENTRIES IN Kmat with  sensitiviy less than sens
  
  sens=0.001;
  Kmat(find(Kmat<sens))=0;
  tic;

      %   keyboard
%   for i=1:size(S,1);
%     if ((i/10)==round(i/10))
%       tleft=((size(S,1)-i)*(toc/i));
%       progress_txt(i,size(S,1),sprintf('Setting up Matrix %6.3f',tleft));
%     end
%     K=Kmat(:,:,i)';
%     Ray=Raymat(:,:,i)';
%     maxK=max(K(:));
%     %  
%     K(find(K< (.001.*maxK) ))=0;
%     gg=K(:)';
%     gg=gg./sum(gg(:));
%     G(i,:)=gg;
%     Gray(i,:)=Ray(:)./sum(Ray(:));
%     rl(i)=raylength(i);
%   end

  % MAKE SURE YOU UNDERSTAND WHY IT IS YY,XX AND NOT XX,YY
  %[yy,xx,zz,]=meshgrid(V.y,V.x,V.z);
  [xx,yy,zz,]=meshgrid(V.x,V.y,V.z);
  
  % WRITE OUTPUT
  fvolgeom=sprintf('visim_volgeom_%s.eas',name);
  fvolsum=sprintf('visim_volsum_%s.eas',name);
  fparfile=sprintf('visim_%s.par',name);
  
  
  if ktype==2;
    nd=length(find(G));
  else
    nd=length(find(Gray));
  end
  VolGeom=zeros(nd,5);
  VolSum=zeros(size(S,1),4);
  
  i=0;
  for iv=1:size(S,1);
    if ktype==2
      g=G(iv,:);
    else
      g=Gray(iv,:);
    end
    id=find(g);
    for ip=1:length(id);
      Garr=[xx(id(ip)) yy(id(ip)) zz(id(ip)) iv g(id(ip))];
      
      i=i+1;
      VolGeom(i,:)=Garr;    
    end
    
    % CALC VELOCITY FROM DT
    v=  rl(iv)./t(iv);
    d_v=abs( v - rl(iv)./(t(iv)+t_err(iv)) );
    VolSum(iv,:)=[iv length(id) v d_v.^2]; 
    
  end

  % 
  disp(sprintf('%s : writing parameter filess',mfilename))
  
  write_eas(fvolgeom,VolGeom);
  
  write_eas(fvolsum,VolSum);
  
  V.parfile=fparfile;
  V.fvolsum.fname=fvolsum;
  V.fvolgeom.fname=fvolgeom;

  write_visim(V);
  V=read_visim(fparfile);
  
