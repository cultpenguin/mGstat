% mps_cond_from_template: find conditional data within template
%
% SIM: simulation grid (NaN-> non simulated nodes)
% [ix,iy,iz]: index of center node in TI
% T: template
% c_cond_max: find maximum number of conditional points
%
% See also: mps_template
%
% NOTE: currently only working in 1D/2D
%
function [d_cond,n_cond]=mps_cond_from_template(SIM,ix,iy,iz,T,n_cond_max)

if isstruct(SIM)
  keyboard
end

[ny,nx,nz]=size(SIM);
d_cond=zeros(1,n_cond_max)-1;

n_cond=0;
i=0;
nT=size(T,1);
while (n_cond<n_cond_max)&(i<nT);
  i=i+1;
  
  x=ix+T(i,1);
  y=iy+T(i,2);
  z=iz+T(i,3);
  
  if (x>0)&(y>0)&(z>0)&(x<=nx)&(y<=ny)&(z<=nz)
    d_cond(i)=SIM(y,x,z);
    if ~isnan(d_cond(i))
      n_cond=n_cond+1;
    end
  else
    d_cond(i)=NaN;
  end
  
end

if n_cond==0
  d_cond=[];
else
  d_cond=d_cond(1:i);
end


