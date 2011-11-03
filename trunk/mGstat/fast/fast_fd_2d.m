% fast_fd_2d : wrapper for the 'fd' eikonal solver from FAST
%
% CALL :
%   t=fast_fd_2d(x,z,V,Sources);
%
%  x,z :  [km]
%  V   :  [m/s]
%
%
% % Example
% X=1:1:100;
% Y=1:1:100;
% V=ones(length(Y),length(X)).*3;
% tmap = fast_fd_2d(X,Y,V,[30,10]);
% contourf(X,Y,tmap);axis image;colorbar
%
%
% 'fd' is an efficient FD soultion of the eikonal equation, and is
% a part of the FAST pacjage created by Colin Zelt :
% http://www.geophysics.rice.edu/department/faculty/zelt/fast.html
%
% TMH/2011
%
function tmap=fast_fd_2d(x,z,V,Sources);
[p,f,s]=fileparts(which('mgstat_verbose'));
if isunix==1
    if ismac==1
        fd_bin=sprintf('%s/bin/nfd_mac_g3',p);
    else
        fd_bin=sprintf('%s/bin/nfd',p);
    end
else
    fd_bin=sprintf('%s\\bin\\nfd.exe',p);
end
% fd_bin='/scratch/tmh/RESEARCH/PROGRAMMING/mGstat/bin/nfd';
% fd_bin='~/bin/nfd';
if exist(fd_bin)==0,
    
    txt=sprintf('----------------------------------------\n');
    txt=sprintf('%sNo valid path to nfd.\n',txt);
    txt=sprintf('%sFAST/NFD is not free for commercial, \n',txt);
    txt=sprintf('%sso you need to manually download and compile the FAST source code from\n ',txt);
    txt=sprintf('%s %s\n',txt,'http://www.geophysics.rice.edu/department/faculty/zelt/fast.html',-10,1);
    txt=sprintf('%sYou can find a hints to easy compilation in the mGstat documentation\n',txt);
    txt=sprintf('%s----------------------------------------\n',txt);
    
    mgstat_verbose(txt);
    return;
end

if ((nargin==0)&(nargout==0))
    disp(fd_bin);
    return
end
if ((nargin==0)&(nargout==1))
    tmap=fd_bin;
    return
end


dx=x(2)-x(1);
dz=z(2)-z(1);
if ( abs(dx-dz)>1e-12 );
    mgstat_verbose(sprintf('%s : 2D grid MUST be unuform DX=DZ. you requested(dx=%g,dz=%g)',mfilename,dx,dz),-10);
    tmap=[];
    return
end


if exist([pwd,filesep,'log.file'],'file') == 2
    % THIS MAKES FAST RUN MUCH FASTER
    try
        delete('log.file');
    catch
    end
end


if length(V)==1
    V=ones(length(z),length(x)).*V;
end
nx=length(x);
nz=length(z);
ns=size(Sources,1);

% MAKE SURE FAST_FD_2D ONLY CALCULATES TMAP ONCE FOR EACH UNIQUE SOURCE
% LOCATION
if ns>1
    SourcesUnique=unique(Sources,'rows');
    nu=length(SourcesUnique);
    if (nu<ns)
        tmapU=fast_fd_2d(x,z,V,SourcesUnique);
        tmap=zeros(nz,nx,ns);
        for j=1:ns
            iu=find( (SourcesUnique(:,1)==Sources(j,1)) & (SourcesUnique(:,2)==Sources(j,2)));
            tmap(:,:,j)=tmapU(:,:,iu);
        end
        return
    end
end



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
        t=read_bin(fname,o.nx,o.nz,1,'uint16').*o.tmax./32767;
    catch
        disp(sprintf('could not read %s',fname));
    end
    %imagesc(t);axis image;drawnow;
    tmap(:,:,i)=t;
end
