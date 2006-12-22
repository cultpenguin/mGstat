% visim_to_G : Setup linear forward matrix (only 2D)
%
% CALL : 
%  [G,d_obs,d_var,Cd,Cm]=visim_to_G(V);
%
function [G,d_obs,d_var,Cd,Cm]=visim_to_G(V);
  
  if isstruct(V)~=1
    V=read_visim(V);
  end
  
  nxyz=V.nx*V.ny*V.nz;
  
  nvol=size(V.fvolsum.data,1);
  
  Gvol=zeros(nvol,nxyz);
 
  for ivol=1:nvol;
    progress_txt(ivol,nvol,'Setting up G')
    idata=find(V.fvolgeom.data(:,4)==ivol);
    POS=V.fvolgeom.data(idata,[1 2 3]);
    SENS=V.fvolgeom.data(idata,[5]);
    
    ix=(POS(:,1)-V.xmn+V.xsiz)/V.xsiz;
    iy=(POS(:,2)-V.ymn+V.ysiz)/V.ysiz;
    iz=(POS(:,3)-V.zmn+V.zsiz)/V.zsiz;
    
    idata=find(V.fvolgeom.data(:,4)==ivol);
    [iix,iiy]=pos2index(POS(:,1),POS(:,2),V.x,V.y);
    ind=sub2ind([V.nx V.ny],iix,iiy);

    Gvol(ivol,ind)=SENS;

    d_volobs(ivol,:)=V.fvolsum.data(ivol,[3]);
    d_volobs_var(ivol,:)=V.fvolsum.data(ivol,[4]);
    
  end

  G=Gvol;
  d_obs=d_volobs; 
  d_var=d_volobs_var;

  
  if nargout<4
    return
  end
  
  % SETTING UP Cd
  Cd_diag=V.fvolsum.data(:,4);
  n=length(Cd_diag);
  Cd=eye(n);
  for i=1:n
    Cd(i,i)=Cd_diag(i);
  end
  
  
  % Setup Covariance matrix
  [yy,xx]=meshgrid(V.y,V.x);
  nxyz=V.nx*V.ny*V.nz;
  %Cm=zeros(nxyz,nxyz);

  
  Va=deformat_variogram(visim_format_variogram(V));
  
  Cm=precal_cov([xx(:) yy(:)],[xx(:) yy(:)],Va);
  
  
  