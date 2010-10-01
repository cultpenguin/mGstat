% sgems_grid : run sgems on GRID
% 
% Ex :
% S=sgems_get_par('snesim_std');
% S.dim.x=[0:.25:5];
% S.dim.y=[0:.25:12];
% S.dim.z=[0];
% S=sgems_grid(S);
%
function S=sgems_grid(S,obs);

if ~isfield(S,'dim'), S.dim.null=0;end
    
if isfield(S.dim,'x');
    S.dim.nx=length(S.dim.x);
    S.dim.x0=S.dim.x(1);
    S.dim.dx=S.dim.x(2)-S.dim.x(1);
    try
        S.dim.dx=S.dim.x(2)-S.dim.x(1);
    catch
        S.dim.dx=0;
    end
end
if isfield(S.dim,'y');
    S.dim.ny=length(S.dim.y);
    S.dim.y0=S.dim.y(1);
    S.dim.dy=S.dim.y(2)-S.dim.y(1);
    try
        S.dim.dy=S.dim.y(2)-S.dim.y(1);
    catch
        S.dim.dy=0;
    end
end
if isfield(S.dim,'z');
    S.dim.nz=length(S.dim.z);
    S.dim.z0=S.dim.z(1);
    try
        S.dim.dz=S.dim.z(2)-S.dim.z(1);
    catch
        S.dim.dz=0;
    end
end

if ~isfield(S.dim,'nx');S.dim.nx=70;end
if ~isfield(S.dim,'ny');S.dim.ny=60;end
if ~isfield(S.dim,'nz');S.dim.nz=1;end

if ~isfield(S.dim,'dx');S.dim.dx=1;end
if ~isfield(S.dim,'dy');S.dim.dy=1;end
if ~isfield(S.dim,'dz');S.dim.dz=1;end

if ~isfield(S.dim,'x0');S.dim.x0=0;end
if ~isfield(S.dim,'y0');S.dim.y0=0;end
if ~isfield(S.dim,'z0');S.dim.z0=0;end


% Generate default python script
[py_script,S]=sgems_grid_py(S);

% delete output eas file
% FEATURE REQ : CHANGE THE TRY_CATCH LOOPS TO CHECK FOR ALGORITHM NAME
% EXPLICITLY
try
    % sgsim, dssim, LU_sim
    property_name=S.XML.parameters.Property_Name.value;
end
try
    % snesim_std
    property_name=S.XML.parameters.Property_Name_Sim.value;
end
if (strcmp(S.XML.parameters.algorithm.name,'tiGenerator'))
    property_name=S.XML.parameters.Ti_prop_name.value;
end

eas_out=sprintf('%s.out',property_name);
if exist([pwd,filesep,eas_out])
    delete([pwd,filesep,eas_out]);
end
eas_out_krig_var=sprintf('%s_krig_var.out',property_name);
if exist([pwd,filesep,eas_out_krig_var])
    delete([pwd,filesep,eas_out_krig_var]);
end
eas_finished='finished';
if exist([pwd,filesep,eas_finished])
    delete([pwd,filesep,eas_finished]);
end

mgstat_verbose(sprintf('%s : Trying to run SGeMS using %s, output to %s',mfilename,py_script,eas_out),11);

sgems(py_script);

% READ DATA EAS DATA OUT FILE
S.data=read_eas(eas_out);

% READ SGEMS OUT FILE
sgems_out=sprintf('%s.sgems',property_name);
if exist(sgems_out)
    O.D=sgems_read(sgems_out);
    S.D=O.D;
end

if exist(eas_out_krig_var);
    S.data_unc=read_eas(eas_out_krig_var);
end
sgems_out_krig_var=sprintf('%s_krig_var.sgems',property_name);
if exist(sgems_out_krig_var)
    S.O_krig_var=sgems_read(sgems_out_krig_var);
end

doReformatSimGrid=1;
try 
    if (strcmp(S.XML.parameters.Secondary_Harddata_Grid.value,S.XML.parameters.Grid_Name.value)==1)
        % NO GRID IS CREATED OF SIM/EST GRID IS THE SAME AS THE SECONDARY
        % GRID
        doReformatSimGrid=0;        
    end
end

if doReformatSimGrid==1;
    S.x=[0:1:(S.dim.nx-1)]*S.dim.dx+S.dim.x0;
    S.y=[0:1:(S.dim.ny-1)]*S.dim.dy+S.dim.y0;
    S.z=[0:1:(S.dim.nz-1)]*S.dim.dz+S.dim.z0;
    
    nsim=size(S.data,2);
    D=zeros(S.dim.nx,S.dim.ny,S.dim.nz,nsim);
    try;S=rmfield(S,'D');end
    for i=1:nsim;
        S.D(:,:,:,i)=reshape(S.data(:,i),S.dim.nx,S.dim.ny,S.dim.nz);
    end
end
if exist([pwd,filesep,eas_finished])
    mgstat_verbose(sprintf('%s : SGeMS ran successfully',mfilename),11);
else
    mgstat_verbose(sprintf('%s : SGeMS FAILED',mfilename),11);
end
