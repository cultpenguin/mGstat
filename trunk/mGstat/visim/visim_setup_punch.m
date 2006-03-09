function [G,Gray]=visim_setup_punch(V,S,R,m_ref);
  
  if nargin==0
    V=read_visim('sgsim_cond_2.par');
  end
  
  if nargin<2
    
    r=load('radar.txt');
    t=r(:,5);
    e=r(:,6);
    
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

  
%  [fvolgeom,fvolsum,G]=visim_tomo_setup(m_ref,V.x,V.y,V.z,S,R,t,dt,name,type)
  
  
  
  G=zeros(size(S,1),length(m_ref(:)));
  Gray=G;
  
  freq=8;
  alpha=1;
  
  for i=1:size(S,1);
    
    progress_txt(i,size(S,1),'Setting up Matrix')
    
    [K,Ray,tS,tR,raypath,raylength]=fresnel_punch(m_ref',V.x,V.y,V.z,[S(i,:),0],[R(i,:),0],freq,alpha,V.xmn,V.ymn,V.zmn,V.xsiz); 
    
    maxK=max(K(:));
    %  
    K(find(K< (.001.*maxK) ))=0;
    gg=K(:)';
    gg=gg./sum(gg(:));
    G(i,:)=gg;
    
    Gray(i,:)=Ray(:)./sum(Ray(:));
    
    rl(i)=raylength;
    
    %  imagesc(reshape(gg,V.nx,V.ny)')
    %  axis image;
    %  caxis([0 0.05])
    %  drawnow;;
    
  end
  
  