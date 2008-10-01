% sgems_read : read an SGeMS binary formmated file
%              both PointSets and CartesianGrids are supported
%
% Call :
%    O=sgems_read('data.sgems');
%
%    O is a matlab structure containing all read information
% 
function O=sgems_read(filename,readdata)

if nargin<1
    help mfilename
    O=[];
    return
end

if nargin<2
    readdata=1;
end

MN=1.561792946e+9; 

fid=fopen(filename,'r');

% READ MAGIC NUMBER
O.magic_number = fread(fid,1,'uint32');

if (O.magic_number==MN)
    mgstat_verbose(sprintf('%s : OK S-GeMS format for %s',mfilename,filename))
else
    mgstat_verbose(sprintf('%s : WRONG S-GeMS format for %s',mfilename,filename),10)
    return
end

pos1=ftell(fid);


% TYPE DEFINITION
[O.type_def]=fread_charstar(fid);

% IF POINT SET
if strcmp(O.type_def,'Point_set')
    disp(sprintf('%s : Reading POINTSET data from %s',mfilename,filename))

    % POINT SET NAME
    [O.point_set]=fread_charstar(fid);
    
    % VERSION 
    O.version = fread(fid,1,'int32','b');

    if (O.version<100)
        mgstat_verbose(sprintf('%s : file too old (%s)',mfilename,file))
        return
    end
    
    % SIZE
    O.n_data = fread(fid,1,'uint32','b');
    O.n_prop = fread(fid,1,'uint32','b');
    
    for i=1:O.n_prop
        [O.property_name{i}]=fread_charstar(fid);
    end
    
    if readdata==0
        return
    end
       
    xyz=zeros(O.n_data,3);
    for j=1:O.n_data
        xyz(j,:)=fread(fid,3,'float32','b')';
    end

    data=zeros(O.n_data,O.n_prop);
    for k=1:O.n_prop
        for j=1:O.n_data
            data(j,k)=fread(fid,1,'float32','b')';
        end
    end
        
    O.data=data;
    O.xyz=xyz;
    
    
elseif strcmp(O.type_def,'Cgrid')
    mgstat_verbose(sprintf('%s : Reading GRID data from %s',mfilename,filename),10);
    
    % POINT SET NAME
    [O.grid_name]=fread_charstar(fid);
    
    % VERSION 
    O.version = fread(fid,1,'int32','b');

    if (O.version<100)
        mgstat_verbose(sprintf('%s : file too old (%s)',mfilename,file))
        return
    end
    
    % SIZE
    % O.n_data = fread(fid,1,'uint32','b');
    n = fread(fid,3,'uint32','b');
    O.nx = n(1);    O.ny = n(2);    O.nz = n(3);
    siz=fread(fid,3,'float32','b');
    O.xsize=siz(1);, O.ysize=siz(2);O.zsize=siz(3);
    or=fread(fid,3,'float32','b');
    O.x0=or(1);, O.y0=or(2);O.z0=or(3);
    
    O.x=[0:1:(O.nx-1)]*O.xsize+O.x0;
    O.y=[0:1:(O.ny-1)]*O.ysize+O.y0;
    O.z=[0:1:(O.nz-1)]*O.zsize+O.z0;

    O.n_prop = fread(fid,1,'uint32','b');

    for i=1:O.n_prop
        O.property{i}=fread_charstar(fid);
    end
    
    if readdata==0
        return
    end
    
    %O.data=zeros(O.n_prop,O.nx*O.ny*O.nz);
    O.data=zeros(O.nx*O.ny*O.nz,O.n_prop);
    O.D=zeros(O.nx,O.ny,O.nz,O.n_prop);
    for i=1:O.n_prop
%        O.data(i,:)=fread(fid,O.nx*O.ny*O.nz,'float32','b');
%        O.D(:,:,:,i)=reshape(O.data(i,:),O.nx,O.ny,O.nz);
        O.data(:,i)=fread(fid,O.nx*O.ny*O.nz,'float32','b');
        O.D(:,:,:,i)=reshape(O.data(:,i),O.nx,O.ny,O.nz);
    end
    
    
    
end

fclose(fid);


function [str,str_len]=fread_charstar(fid);
    str_len = fread(fid,1,'uint32','b');
    str = fread(fid,str_len,'char');
    str = char(str(1:(str_len-1))');
