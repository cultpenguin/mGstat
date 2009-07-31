% fast_fd_2d_chunk : wrapper for the 'fd' eikonal solver from FAST
%
% CALL : 
%   t=fast_fd_2d(x,z,V,Sources);
%
%  x,z :  [km]
%  V   :  [m/s]
%
%
% 'fd' is an efficient FD soultion of the eikonal equation, and is 
% a part of the FAST pacjage created by Colin Zelt :
% http://www.geophysics.rice.edu/department/faculty/zelt/fast.html
%
% TMH/2006
%
function tmap=fast_fd_2d_chunk(x,z,V,Sources);

  
  nx=length(x);
  nz=length(z);
  ns=size(Sources,1);
    
  tmap=zeros(nz,nx,ns);
  
  chunk_size=99;
  
  i2=0;
  
  for ichunk=1:ceil(ns/chunk_size);

    i1=i2+1;
    i2=i2+chunk_size;
        if i2>ns, i2=ns;
    end
    
    %disp(sprintf('is=%d i2=%d ichunk=%d',i1,i2,ichunk))
    
    tmap(:,:,i1:i2)=fast_fd_2d(x,z,V,Sources(i1:i2,:));
    
  end
  
  