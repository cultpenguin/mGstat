% sgems_write_grid : write binary formatted SGEMS grid
%
% CALL :
%   sgems_write_grid(x,y,z,data,filename,grid_name,property);
%
%  %%% Example (make WIND data set in proper format and save in SGEMS format): 
%  load wind;
%  x_data=squeeze(x(1,:,1));
%  y_data=squeeze(y(:,1,1));
%  z_data=squeeze(z(1,1,:));
%  property{1}='u';
%  property{2}='v';
%  property{3}='w';
%
%  % Example (Use data in cell/matrix format and convert to SGEMS format): 
%  data{1}=u; % MUST BE IN SIZE [ny,nx,nz] or [nx,ny,nz] 
%  data{2}=v; % MUST BE IN SIZE [ny,nx,nz] or [nx,ny,nz]  
%  data{3}=w; % MUST BE IN SIZE [ny,nx,nz] or [nx,ny,nz]   
%  sgems_write_grid(x_data,y_data,z_data,data,'wind-1.sgems','wind',property);
%
%  % Example (As above, but reshape matrix into correcr format): 
%  nz=length(z_data);
%  for iz=1:nz % % Reshape from size [ny,nx,nz] to [nx,ny,nz]  
%    d1(:,:,iz)=transpose(u(:,:,iz));
%    d2(:,:,iz)=transpose(v(:,:,iz));
%    d3(:,:,iz)=transpose(w(:,:,iz));
%  end
%  data{1}=d1;data{2}=d2;data{3}=d3;
%  sgems_write_grid(x_data,y_data,z_data,data,'wind-3.sgems','wind',property);
%
% % Eaxmple (convert data input to column in data matrix and convert to XYZ)
% sgems_write_grid(x_data,y_data,z_data,[d1(:) d2(:) d3(:)],'wind-2.sgems','wind',property);
%
% 
%
%
% See also: sgems_write, sgems_write_pointset, sgems_read, sgems2eas, eas2sgems
%
function sgems_write_grid(x,y,z,data,filename,grid_name,property);

if nargin<5
    filename='ti.sgems';
end

if nargin<6
    grid_name='GRIDNAME';
end
if nargin<7
    for i=1:size(data,2)
        property{i}=sprintf('P%d',i);
    end
end
if (ischar(property));
    property_tmp=property;
    clear property;
    property{1}=property_tmp;
end
  


% REPLACE NAN with SGEMS NaN VALUE (-9966699)
try
    data(find(isnan(data)))=-9966699;
end

O.type_def='Cgrid';

O.x0=x(1);
O.y0=y(1);
O.z0=z(1);

dx=1;dy=1;dz=1;

try;dx=x(2)-x(1);end
try;
    dy=y(2)-y(1);
catch
    dy=dx;
end
try;
    dz=z(2)-z(1);
catch
    dz=dy;
end

O.xsize=dx;
O.ysize=dy;
O.zsize=dz;

O.nx=length(x);
O.ny=length(y);
O.nz=length(z);

if iscell(data)
    nd=length(data);
    if (size(data{1},1)==O.nx)&(size(data{1},2)==O.ny)&(size(data{1},3)==O.nz)
        mgstat_verbose(sprintf('%s : data in proper matrix format',mfilename),2);
        % OK FORMAT
        for i=1:nd
            O.data(:,i)=data{i}(:);
        end
    elseif (size(data{1},2)==O.nx)&(size(data{1},1)==O.ny)&(size(data{1},3)==O.nz)
        mgstat_verbose(sprintf('%s : need to transpose dims 1 and 2 in matrix format',mfilename),2);
        % NEED TO TRANSPOSE DIMS 1 and 2
        for i=1:nd
            clear d
            for iz=1:O.nz % % Reshape from size [ny,nx,nz] to [nx,ny,nz]
                d(:,:,iz)=transpose(data{i}(:,:,iz));
            end
            O.data(:,i)=d(:);
        end
    else

    end

else
    % WE ASSUME DATA IS ALLREADY IN PROPER COLUMN FORMAT
    mgstat_verbose(sprintf('%s : assumes data is in corrent column format',mfilename),2);
    O.data=data;
end


O.grid_name=grid_name;
O.property=property;

sgems_write(filename,O);