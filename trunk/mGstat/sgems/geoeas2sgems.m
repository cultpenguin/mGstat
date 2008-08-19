% geoeas2sgems : convert geoeas ASCII to SGeMS binary file (using g2s) 
%
%
function file_sgems=geoeas2sgems(file_eas,object_name,object_type,object_dim)

%[data,header]=read_eas(file_eas);

if nargin<2
    object_name='grid';
end
if nargin<3
    object_type=0; % point_set
    object_type=1; % grid
end
if nargin<4
    object_dim=0; % 2D
%    object_dim=1; % 3D
end
    
nx=10;ny=26;nz=10;
dx=1;dy=1;dz=1;
x0=1;y0=1;z0=1;
nsim=1;
nanval=-99999;


[p,f,c]=fileparts(file_eas);
file_sgems=[f,'.sgems'];

fid=fopen('geoeas2sgems.par','w');
fprintf(fid,'%s   %% file containing the geoeas object\n',file_eas);
fprintf(fid,'%s   %% output sgems file\n',file_sgems);
fprintf(fid,'%s   %% object name\n',object_name);
fprintf(fid,'%d   %% object type, pointset (0), grid (1)\n',object_type);
fprintf(fid,'%d   %% object dim (for pointset), 2D(0), 3D(0)\n',object_dim);
fprintf(fid,'%d %d %d  %% nx ny nz\n',nx,ny,nz);
fprintf(fid,'%f %f %f  %% dx dy dz\n',dx,dy,dz);
fprintf(fid,'%f %f %f  %% x0 y0 z0\n',x0,y0,z0);
fprintf(fid,'%d        %% nsim\n',nsim);
fprintf(fid,'%f        %% nsim\n',nanval);

fclose(fid);


[p,f]=fileparts(gstat_binary);
exe=[p,filesep,'g2s'];
[status,result]=system(exe);
if (strcmp(result(1:19),'Finished converting'))
    % OK CONVERSION
    mgstat_verbose(sprintf('%s : Successfully converted %s to %s',mfilename,file_eas,file_sgems),10)
else
    mgstat_verbose(sprintf('%s : Could not convert %s',mfilename,file_eas),10)
    mgstat_verbose(sprintf('%s : error :  %s',mfilename,result),10)
end
