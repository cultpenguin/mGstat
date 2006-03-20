% fast_fd_2d : wrapper for the 'fd' eikonal solver from FAST
function t=fast_fd_2d(x,z,V,Sources);
  
  % MAKE LOTYS OF TEST THAT V IS CORRECTLY SHAPED
  %
  nx=length(x);
  nz=length(z);
  
  fd_bin='~/bin/nfd';
  
  % WRITE VELOCITY FILE
  write_bin('vel.mod',V,1,'int16');

 
  % WRITE FASTY 'fd' parameter files  
  o=fast_fd_write_par(Sources(:,1),Sources(:,2));
  
  % RUN 'fd'
  unix(fd_bin);
  
  % READ OUTPUT
  t=read_bin('fd01.times',nx,nz,1,'uint16').*o.tmax./32766;
