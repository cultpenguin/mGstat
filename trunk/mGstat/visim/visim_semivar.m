% [gamma,hc,np,av_dist,Mxyz,Md]=visim_semivar(V,usesim,angle,tol)
function [gamma,hc,np,av_dist,Mxyz,Md]=visim_semivar(V,usesim,angle,tol,cutoff,width)
  
  if isstruct(V)~=1
    V=read_visim(V);
  end
      
  if nargin<2
    usesim=1;
  end
  
  if nargin<3
    angle=0;
  end
  
  if nargin<4
    tol=180;
  end

  if nargin<5
    cutoff=sqrt((max(V.x)-V.x(1)).^2+ (max(V.y)-V.y(1)).^2 + (max(V.z)-V.z(1)).^2);
    cutoff=str2num(sprintf('%12.1g',cutoff))
  end
  if nargin<6
    width=cutoff/15;
    width=str2num(sprintf('%12.1g',width))
  end

  nsim=length(usesim);
  
  usex=[1:1:V.nx];
  usey=[1:1:V.ny];
  %usey=[1:1:40];
  V.nx=length(usex);
  V.ny=length(usey);

  
  [xx,yy,zz]=meshgrid(V.x(usex),V.y(usey),V.z);  
  xx=xx';
  yy=yy';
  zz=zz';
  
  nxyz=V.nx*V.ny*V.nz;
  Mxyz=[xx(:) yy(:) zz(:)];
  
  for isim=1:nsim
       
    Md=V.D(usex,usey,usesim(isim));    
    Md=Md(:);

    [gamma(:,isim),hc,np(:,isim),av_dist(:,isim)]=calc_gstat_semivar(Mxyz,Md,angle,tol,cutoff,width);
   
  end
  
  