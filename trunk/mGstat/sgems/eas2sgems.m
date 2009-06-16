% eas2sgems : convert eas ASCII file to SGEMS binary point set
%
% EAS can be treated either as POINT files or GRID files.
%
% EAS Point-set files
% The data section starts with 'ndim' columns defining 
% the location in ndim-space, followed by N columns of DATA.
% Call :
%   O=eas2sgems(file_eas,file_sgems,ndim);
%
% Examples:
%
% -- 3d eas files with two data sets (5 cols, 3dims)
%  ndim=3
%  eas2sgems('file.eas','file.sgems',ndim)
%
% -- 2d eas files with two data sets (5 cols, 2dims)
%  ndim=2
%  eas2sgems('file.eas','file.sgems',ndim)
%
%
% EAS Grid files
% The data section consist of N colums, representing N grids.
% An EAS not does not contain information about 
% the cell size (dx,dy,dx) cell size, or the
% location of the first cell for each dimension (x0,y0,z0).
% It 'may' (not part of strict format) contain information about the size
% of the rid in the first line 'xxxxx (90x10x1);
% Call
%    O=eas2sgems(file_eas,file_sgems,nx,ny,nz,dx,dy,dz,x0,y0,z0);
%
% -- Grid EAS with dim in header '(60x70x1)':
%    eas2sgems('file.eas','file.sgems'); 
%    this assumes (dx,dy,dz)=(1,1,1), (x0,y0,z0)=(0,0,0)
%
% -- Same as above, but all manual::
%    eas2sgems('file.eas','file.sgems',60,70,1,1,1,1,0,0,0); 
% -- As abobe, but (x0,y0,z0)=(10,10,6)
%    eas2sgems('file.eas','file.sgems',60,70,1,10,10,6,0,0,0); 
%
%
%

function O=eas2sgems(file_eas,file_sgems,ndim,ny,nz,dx,dy,dz,x0,y0,z0);

[p,f,e]=fileparts(file_eas);
if isempty(p); p=pwd;end
file_sgems_ex=[p,filesep,f,'.sgems'];

if nargin<2, file_sgems=file_sgems_ex;end
if isempty(file_sgems), file_sgems=file_sgems_ex;end

Dset='grid';
if nargin<3, Dset='grid';end
if nargin==3, Dset='point';end
    
[data,header,title]=read_eas(file_eas);

if strcmp(Dset,'point');
    % POINT SET
    ncols=size(data,2);
    O.n_data=size(data,1);
    O.n_prop=ncols-ndim;
    O.xyz=zeros(O.n_data,3);

    for idim=1:ndim
        O.xyz(:,idim)=data(:,idim);
    end

    O.property_name=header((ndim+1):ncols);
    O.data=data(:,(idim+1):size(data,2));

    O.point_set=title;

else
    % GRID SET

    if nargin==2
        try
            x_pos=findstr('x',title);
            dl=findstr('(',title);
            dr=findstr(')',title);
            if (~isempty(dl)&~isempty(dr) &(length(x_pos)>=2));
                x_pos=x_pos( (length(x_pos)-1):length(x_pos));
                dl=dl(length(dl));
                dr=dr(length(dr));

                O.nx=str2num(title( (dl+1) : (x_pos(1)-1)));
                O.ny=str2num(title( (x_pos(1)+1) : (x_pos(2)-1)));
                O.nz=str2num(title( (x_pos(2)+1) : (dr-1) ));

            end
        catch
            mgstat_verbose(sprintf('%s : Could NOT extract [nx,ny,nx] from header of %s',mfilename,file_eas))
        end
        mgstat_verbose(sprintf('%s : Using (nx,ny,nz)=(%d,%d,%d) found in %s',mfilename,O.nx,O.ny,O.nz,file_eas),10);
    elseif nargin>=5
        nx=ndim;
        O.nx=nx;O.ny=ny;O.nz=nz;
    elseif ((nargin==3)|(nargin==4))
        mgstat_verbose(sprintf('%s : you MUST supply at least (nx,ny,nz) describing the grid(s) in %s',mfilename,file_eas),10);
        O.null=[];
        return
    end

    if nargin<6; O.xsize=1; else; O.xsize=dx; end
    if nargin<7; O.ysize=1; else; O.ysize=dy; end
    if nargin<8; O.zsize=1; else; O.zsize=dz; end

    if nargin<9; O.x0=0; else; O.x0=x0; end
    if nargin<10; O.y0=0; else; O.y0=y0; end
    if nargin<11; O.z0=0; else; O.z0=z0; end

    nxyz=prod([O.nx,O.ny,O.nz]);
    n_prop_app=length(data)./nxyz;
    if n_prop_app==round(n_prop_app)
        mgstat_verbose(sprintf('More data than the dimension given',mfilename))
        mgstat_verbose(sprintf('trying to save extra data as extra properties',mfilename))
        if n_prop_app~=length(header);
            h=header{1};
            for i=1:n_prop_app                
                header{i}=sprintf('%s_%d',h,i);
            end
        end
        O.n_prop=n_prop_app;    
        O.data=reshape(data(:),[nxyz,n_prop_app]);
    else
        O.n_prop=length(header);
        O.data=data;
    end    
    O.property=header;
    O.grid_name=title;
   
end

O=sgems_write(file_sgems,O);


