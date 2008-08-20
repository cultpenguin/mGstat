% geoeas2sgems : convert geoeas ASCII to SGeMS binary file (using g2s) 
%
% Call : 
%    file_sgems=geoeas2sgems(file_eas,object_name,object_type,object_dim)
%
%    file_eas [string] : eas filename to convert
%    object.name [string]
%    object.type [int] : 0:point_set, 1:grid
%    object.dim  [int] : 0:2D, 1:3D
%
%    The following parameters are only neede when object.type=1 (grid)
%    object.x  [array] OR
%    object.nx, object.dx, object.x0
%    
%    object.y  [array] OR
%    object.ny, object.dy, object.xy
%
%    object.z  [array] OR
%    object.nz, object.dz, object.xz
%
%
%    object.nsim [int] : number of simulations
%    object.nanval [int] : NAN value
%
%    object.keep_eas [int]: 1:keep eas file, 2: delete eas file
%
%function file_sgems=geoeas2sgems(file_eas,object_name,object_type,object_dim)
function [file_sgems,object]=geoeas2sgems(file_eas,object)

%[data,header]=read_eas(file_eas);

if nargin<2
    object.null='';
    object_name='grid';
end

if ~isfield(object,'name');object.name='grid';end
if ~isfield(object,'type');
    object.type=0; % point_set
    %object.type=1; % grid
end
if ~isfield(object,'dim');
    object.dim=0; % 2D
    %object.dim=1; % 3D
end
    
if isfield(object,'x');
    object.nx=length(object.x);
    object.x0=object.x(1);
    try
        object.dx=object.x(2)-object.x(1);
    catch
        object.dx=1;
    end
 
end
if isfield(object,'y');
    object.ny=length(object.y);
    object.y0=object.y(1);
    try
        object.dy=object.y(2)-object.y(1);
    catch
        object.dy=1;
    end
end
if isfield(object,'z');
    object.nz=length(object.z);
    object.z0=object.z(1);
    try
        object.dz=object.y(2)-object.z(1);
    catch
        object.dz=1;
    end
end

if ~isfield(object,'nx'); object.nx=1;end
if ~isfield(object,'ny'); object.ny=1;end
if ~isfield(object,'nz'); object.nz=1;end

if ~isfield(object,'dx'); object.dx=1;end
if ~isfield(object,'dy'); object.dy=1;end
if ~isfield(object,'dz'); object.dz=1;end

if ~isfield(object,'x0'); object.x0=0;end
if ~isfield(object,'y0'); object.y0=0;end
if ~isfield(object,'z0'); object.z0=0;end

if ~isfield(object,'nsim'); object.nsim=1;end
if ~isfield(object,'nanval'); object.nanval=-99999;end

if ~isfield(object,'keep_eas'); object.keep_eas=1;end

[p,f,c]=fileparts(file_eas);
file_sgems=[f,'.sgems'];

fid=fopen('geoeas2sgems.par','w');
fprintf(fid,'%s   %% file containing the geoeas object\n',file_eas);
fprintf(fid,'%s   %% output sgems file\n',file_sgems);
fprintf(fid,'%s   %% object name\n',object.name);
fprintf(fid,'%d   %% object type, pointset (0), grid (1)\n',object.type);
fprintf(fid,'%d   %% object dim (for pointset), 2D(0), 3D(0)\n',object.dim);
fprintf(fid,'%d %d %d  %% nx ny nz\n',object.nx,object.ny,object.nz);
fprintf(fid,'%f %f %f  %% dx dy dz\n',object.dx,object.dy,object.dz);
fprintf(fid,'%f %f %f  %% x0 y0 z0\n',object.x0,object.y0,object.z0);
fprintf(fid,'%d        %% nsim\n',object.nsim);
fprintf(fid,'%f        %% nsim\n',object.nanval);

fclose(fid);


[p,f]=fileparts(gstat_binary);
exe=[p,filesep,'g2s'];
[status,result]=system(exe);
if (strcmp(result(1:19),'Finished converting'))
    % OK CONVERSION
    mgstat_verbose(sprintf('%s : Successfully converted %s to %s',mfilename,file_eas,file_sgems),10)
    try
        delete('geoeas2sgems.par');
    end
    if object.keep_eas==0
        try
            delete(file_eas);
        end
    end        
else
    mgstat_verbose(sprintf('%s : Could not convert %s',mfilename,file_eas),10)
    mgstat_verbose(sprintf('%s : error :  %s',mfilename,result),10)
end
