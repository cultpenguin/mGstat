% visim_lsq : least squares inversion of visim data
function [m_est]=visim_lsq(V);
  
  if isstruct(V)~=1
    V=read_visim(V);
  end
  
  [G,d_obs,d_var]=visim_to_G(V);
  
  nxyz=size(G,2);
  nvol=size(G,1);

    
  Cd=zeros(nvol,nvol);
  for i=1:nvol;
    Cd(i,i)=d_var(i);
  end
  
  Cm=zeros(nxyz,nxyz);
  for i=1:nxyz;
    Cm(i,i)=V.gvar;%mean(diag(Cd));
  end
 
  
  m0=zeros(nxyz,1)+V.gmean;
  
  [m_est]=estim_taran(G,Cm,Cd,m0,d_obs);  
  %Cd=Cd.*.1;
  %[m_est2]=estim_taran(G,Cm,Cd,m0,d_obs);  
  %clear Cm
  