function [V,G,Gray,rl]=visim_setup_punch(V,S,R,m_ref,t,t_err,name,ktype,doPlot);

%
%
% CHANGE THIS FILE TO POINT TO TWO FILES :
% visim_setup_tomo_geometry
% visim_setup_tomo_observations
%
  
  
  if nargin==0
    V=read_visim('sgsim_cond_2.par');
  end
  
  if nargin<6
    name='';
  end
  
  if nargin<7
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
  alpha=1;
  
  for i=1:size(S,1);
    
    progress_txt(i,size(S,1),'Setting up Matrix')
    
    [K,Ray,tS,tR,raypath,raylength]=fresnel_punch(m_ref',V.x,V.y,V.z,[S(i,:),0],[R(i,:),0],freq,alpha,V.xmn,V.ymn,V.zmn,V.xsiz,doPlot); 
    
    K=K';
    Ray=Ray';
    
    maxK=max(K(:));
    %  
    K(find(K< (.001.*maxK) ))=0;
    gg=K(:)';
    gg=gg./sum(gg(:));
    G(i,:)=gg;
    
    Gray(i,:)=Ray(:)./sum(Ray(:));

    rl(i)=raylength;



    
  end

  % MAKE SURE YOU UNDERSTAND WHY IT IS YY,XX AND NOT XX,YY
  [yy,xx,zz,]=meshgrid(V.y,V.x,V.z);
  
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
  
