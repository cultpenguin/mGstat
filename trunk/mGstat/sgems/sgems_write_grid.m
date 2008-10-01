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
O.type_def='Cgrid';

O.x0=x(1);
O.y0=y(1);
O.z0=z(1);

dx=1;dy=1;dz=1;

try;dx=x(2)-x(1);end
try;dy=y(2)-y(1);end
try;dz=z(2)-z(1);end

O.xsize=dx;
O.ysize=dy;
O.zsize=dz;

O.nx=length(x);
O.ny=length(y);
O.nz=length(z);

O.data=data;

O.grid_name=grid_name;
O.property=property;

sgems_write(filename,O);