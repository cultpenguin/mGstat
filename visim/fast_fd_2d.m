% fast_fd_2d : wrapper for the 'fd' eikonal solver from FAST
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
function t=fast_fd_2d(x,z,V,Sources);

  V_gain=1000;

  V=V.*V_gain;
  
  fd_bin='/scratch/tmh/RESEARCH/PROGRAMMING/mGstat/bin/nfd';
  if exist(fd_bin)==0,
    disp(sprintf('%s - NO VALID PATH TO nfd',mfilename));
  end
  
  % MAKE LOTYS OF TEST THAT V IS CORRECTLY SHAPED
  %

  % WRITE VELOCITY FILE
  write_bin('vel.mod',V,1,'int16');

 
  % WRITE FAST 'fd' parameter files  
  o.xmin=min(x);
  o.xmax=max(x);
  o.ymin=0;
  o.ymax=0;
  o.zmin=min(z);
  o.zmax=max(z);
  o.dx=x(2)-x(1);
  o.nx=length(x);
  o.ny=1;
  o.nz=length(z);
  o.tmax=200;
  o.tmax=V_gain.*( sqrt( (max(x)-min(x)).^2 +  (max(z)-min(z)).^2 )) ./ min(V(:));
  o=fast_fd_write_par(Sources(:,1),Sources(:,2),o);
  
  % RUN 'fd'
  unix(fd_bin);
  
  % READ OUTPUT
  t=read_bin('fd01.times',o.nx,o.nz,1,'uint16').*o.tmax./32766;
