function S=sgems_grid(S,obs);

% Generate default python script
[py_script,S,XML]=sgems_grid_py(S);

% delete output eas file
eas_out=sprintf('%s.out',XML.parameters.Property_Name.value);
if exist([pwd,filesep,eas_out])
    delete([pwd,filesep,eas_out]);
end
eas_finished='finished';
if exist([pwd,filesep,eas_finished])
    delete([pwd,filesep,eas_finished]);
end

mgstat_verbose(sprintf('%s : Trying to run SGeMS using %s, output to %s',mfilename,py_script,eas_out),11);

sgems(py_script);

eas_out=sprintf('%s.out',XML.parameters.Property_Name.value);


S.data=read_eas(eas_out);

S.x=[0:1:(S.dim.nx-1)]*S.dim.dx+S.dim.x0;
S.y=[0:1:(S.dim.ny-1)]*S.dim.dy+S.dim.y0;
S.z=[0:1:(S.dim.nz-1)]*S.dim.dz+S.dim.z0;

nsim=size(S.data,2);
D=zeros(S.dim.nx,S.dim.ny,S.dim.nz,nsim);
for i=1:nsim;
    S.D(:,:,:,i)=reshape(S.data(:,i),S.dim.nx,S.dim.ny,S.dim.nz);
end

if exist([pwd,filesep,eas_finished])
    mgstat_verbose(sprintf('%s : SGeMS ran successfully',mfilename),11);
else
    mgstat_verbose(sprintf('%s : SGeMS FAILED',mfilename),11);
end
