% visim_setup_tomo_kernel : Setup sensitivity kernel for VISIM tomography
% 
% CALL :
%    visim_setup_tomo_kernel(V,S,R,m_ref,t,t_err,name,options);
%
% V: VISIM matlab structure
% S: [Nvol,2] list of sources for each volume
% R: [Nvol,2] list of Receivers for each volume
% t: [Nvol,1] List of observed travel times for each volume
% t_err: [Nvol,1] List of observed travel times measurement errors
% optional
% options : matlab structure with optional options:
%   options.name: [string] name to append to VISIM geomtery files
%
%    options.parameterization: [integer]
%       options.parameterization=1, SLOWNESS PARAMETERIZATION
%       options.parameterization=2, VELOCITY PARAMETERIZATION (default)
%
%   options.ktype [int]  [1] High Freq Approx (rays) [2] Fresnel zone sensitivity 
%   options.freq: [float], def=10; for ktype=2; See also munk_fresenl_2d
%   options.alpha: [float], def= 1; for ktype=2; See also munk_fresenl_2d
%
%
%   options.doPlot : [0] No plotting [1] some plotting [2] most plotting.
%
% See also : kernel, fast_fd_2d, munk_fresnel_2d
%
% TMH/2006
%
function [V,G,Gray,rl]=visim_setup_tomo_tkernel(V,S,R,m_ref,t,t_err,name,options);

  if exist('options','var')==0
      options.null=[],
  end
  
  if isfield(options,'ktype')==0
      ktype=1; % RAY/HIGH FREQ
      %ktype=2; % FINITE FREQ
  else
      ktype=options.ktype;
  end

  if isfield(options,'freq')==0
      freq=10;
  else
      freq=options.freq;
  end

  if isfield(options,'alpha')==0
      alpha=1.0;
  else
      alpha=options.alpha;
  end

    if isfield(options,'parameterization')==0
      parameterization=2; % VELOCITY
      % parameterization=1; % SLOWNESS
  else
      parameterization=options.parameterization;
  end


  if isfield(options,'doPlot')==0
      doPlot=0;
  else
      doPlot=options.doPlot;
  end

  
  

  %doPlot=0;
  if nargin==0
    V=read_visim('sgsim_cond_2.par');
  end
  
  if nargin<7
    name='';
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
    m_ref=reshape(m_ref,49,21)';
  end

  if nargin<9
      T=8;
  end
  if nargin<10
      doPlot=0;
  end

  
  if isempty(t)
    t=ones(size(S,1));
    t_err=ones(size(S,1));
  end
  
  if exist('doPlot')==0
    doPlot=0;
  end
  
  disp(sprintf('%s : %s.par',mfilename,name))
  
  G=zeros(size(S,1),length(m_ref(:)));
  Gray=G;
  
  [Kmat,Raymat,G,Gray,tS,tR,raypath,rl]=kernel_multiple(m_ref',V.x,V.y,V.z,[S],[R],freq,alpha,doPlot); 
  
  
 
  if parameterization==1
      mgstat_verbose(sprintf('%s : USE SLOWNESS PARAMETERIZATION',mfilename))
      % USE SLOWNESS PARAMETERIZATION
      d_obs=t(:);
      d_std=t_err(:);
      
  elseif parameterization==2
      mgstat_verbose(sprintf('%s : USE VELOCITY PARAMETERIZATION',mfilename))
      % USE VELOCITY PARAMETERIZATION
      %convert to velocity
      d_obs = rl(:)./t(:);
      d_std =  abs((rl(:)./(t(:)+t_err(:))-rl(:)./(t(:)-t_err(:)))./2);

      %normalize kernel for velocity parameterization
      for iv=1:size(S,1);
          G(iv,:)=G(iv,:)./(rl(iv));
          Gray(iv,:)=Gray(iv,:)./(rl(iv));
          Kmat(:,:,iv)=Kmat(:,:,iv)./rl(iv);
          Raymat(:,:,iv)=Raymat(:,:,iv)./rl(iv);
      end
  end
     
  
  % WRITE KERNEL TO DISK
  
  sens=0.001;
  Kmat(find(Kmat<sens))=0;
  tic;

  % MAKE SURE YOU UNDERSTAND WHY IT IS YY,XX AND NOT XX,YY
  %[yy,xx,zz,]=meshgrid(V.y,V.x,V.z);
  [xx,yy,zz,]=meshgrid(V.x,V.y,V.z);
  
  % WRITE OUTPUT
  fvolgeom=sprintf('visim_volgeom_%s.eas',name);
  fvolsum=sprintf('visim_volsum_%s.eas',name);
  fparfile=sprintf('%s.par',name);
  

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
   VolSum(iv,:)=[iv length(id) d_obs(iv) d_std(iv).*d_std(iv)]; 
   
  end

  % 
  disp(sprintf('%s : writing parameter files %s, %s',mfilename,fvolgeom,fvolsum))
  
  write_eas(fvolgeom,VolGeom);
  
  write_eas(fvolsum,VolSum);
  
  V.parfile=fparfile;
  V.fvolsum.fname=fvolsum;
  V.fvolgeom.fname=fvolgeom;

  write_visim(V);
  V=read_visim(V.parfile);
  
