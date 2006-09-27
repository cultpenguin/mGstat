
% fast_fd_2d : wrapper for the 'fd' eikonal solver from FAST
%
% CALL : 
%   t=fast_fd_2d(x,z,V,Sources);
%
%  x,z :  [km]
%  V   :  [m/s]
%
%
% Run fast_fd_2d with no arguments to run e demonstration.
%
%
% 'fd' is an efficient FD soultion of the eikonal equation, and is 
% a part of the FAST pacjage created by Colin Zelt :
% http://www.geophysics.rice.edu/department/faculty/zelt/fast.html
%
% TMH/2006
%
function tmap=fast_fd_2d(x,z,V,Sources);
    
    
    [p,f,s]=fileparts(which('visim'));  
    if isunix==1
        fd_bin=sprintf('%s/../bin/nfd',p);
    else
        fd_bin=sprintf('%s\\..\\bin\\nfd.exe',p);
    end    
    % fd_bin='/scratch/tmh/RESEARCH/PROGRAMMING/mGstat/bin/nfd';
    % fd_bin='~/bin/nfd';
    if exist(fd_bin)==0,
        disp(sprintf('%s - NO VALID PATH TO nfd',mfilename));
        return;
    end
    
    if ((nargin==0)&(nargout==0))
        disp(fd_bin);
        return
    end
    
    
    if nargin==0
        nx=110;
        nz=80;
        x=[1:1:nx].*1;
        z=[1:1:nz].*1;
        V=ones(nz,nx)*2;
        V(1:(nz/2),:)=4;
        
        Sources=[10 10];
        
        t=fast_fd_2d(x,z,V,Sources);
        
        contourf(x,z,t);
        axis image
    end
  
  nx=length(x);
  nz=length(z);
  ns=size(Sources,1);  

  % CHECK SIZE OF V,nx,nz
  if (sum(size(V)==[nz nx])~=2)
    disp('Wrong format of (x,z) or V')
    disp('check that ')
    disp('   size(V) == [nz,nx] ')
    tmap=[];
    return
  end

  
  % CHECK SIZE OF Sources
  if (size(Sources,2)~=2)
    disp('ONLY 2D is supported right now')
    disp('check that ')
    disp('   size(S) == 2 ')
    tmap=[];
    return
  end

  if ns>99
    tmap = fast_fd_2d_chunk(x,z,V,Sources);
    return
  end
  
  
  V_gain=1000;

  V=V.*V_gain;

  
  % MAKE LOTYS OF TEST THAT V IS CORRECTLY SHAPED
  %
  nx=length(x);
  nz=length(z);
  ns=size(Sources,1);  
  
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
    
  tmap=zeros(nz,nx,ns);
  
  for i=1:size(Sources,1);
  
    
    orgCode=1;
    if (orgCode),
      % ORG CODE fdXX
      if i<10,
        fname=sprintf('fd0%d.times',i);
      elseif i<100
        fname=sprintf('fd%d.times',i);
      end    
    else
      % EDITED FAST CODE fdXXX
      if i<10,
        fname=sprintf('fd00%d.time',i);
      elseif i<100
        fname=sprintf('fd0%d.time',i);
      elseif i<1000
        fname=sprintf('fd%d.time',i);
      end    
    end
    
    
    
    
    % READ OUTPUT
    try
      t=read_bin(fname,o.nx,o.nz,1,'uint16').*o.tmax./32766;
    catch
      disp(sprintf('could not read %s',fname));
    end
    %imagesc(t);axis image;drawnow;
    tmap(:,:,i)=t;
  end