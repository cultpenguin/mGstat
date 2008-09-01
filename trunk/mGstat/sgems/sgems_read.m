function O=sgems_read(filename)

if nargin<1
    help mfilename
    O=[];
    return
end

MN=1.561792946e+9; 

fid=fopen(filename,'r');

% READ MAGIC NUMBER
O.magic_number = fread(fid,1,'uint32');

if (O.magic_number==MN)
    mgstat_verbose(sprintf('%s : OK S-GeMS format for %s',mfilename,filename))
else
    mgstat_verbose(sprintf('%s : WRONG S-GeMS format for %s',mfilename,filename))
    return
end

pos1=ftell(fid);


% TYPE DEFINITION
O.type_def = fread(fid,1,'uint32','b');

% TYPE DEFINITION STRING
type_def_string = fread(fid,10,'char');
O.type_def_string = char(type_def_string(1:9)');

% IF POINT SET
if O.type_def==10
    disp(sprintf('%s : Reading POINTSET data from %s',mfilename,filename))

    % POINT NAME
    O.point_set_name_size = fread(fid,1,'uint32','b');
    point_set_name = fread(fid,O.point_set_name_size,'char');
    O.point_set_name=char(point_set_name');

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
        O.P{i}.property_name_size = fread(fid,1,'uint32','b');
        property_name = fread(fid,O.P{i}.property_name_size,'char');
        O.P{i}.property_name=char(property_name');       
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
    
    
elseif O.type_def==6
    mgstat_verbose(sprintf('%s : Reading GRID data from %s',mfilename,filename),10);
end

fclose(fid);