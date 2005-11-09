function [gamma,hc,np,av_dist,Mxyz,Md]=visim_semivar(V,usesim,angle,tol,etype)
  
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
    try 
      etype=V.etype.mean;
    catch
      etype=0;
    end
  end
  
  
  nsim=length(usesim);
  
  [xx,yy,zz]=meshgrid(V.x,V.y,V.z);  
  xx=xx';
  yy=yy';
  zz=zz';
  
  nxyz=V.nx*V.ny*V.nz;
  Mxyz=[xx(:) yy(:) zz(:)];
  
  
  
  
  for isim=1:nsim
       
    Md=V.D(:,:,usesim(isim));    
    %Md=V.D(:,:,usesim(isim))-etype;    
    Md=Md(:);

    [gamma(:,isim),hc,np(:,isim),av_dist(:,isim)]=calc_gstat_semivar(Mxyz,Md,angle,tol);
   
  end
  
  