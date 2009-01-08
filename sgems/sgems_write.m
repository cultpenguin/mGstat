% sgems_write : write sgems binary data structure
%
% Call:
%   O=sgems_write(filename,O)
%
%   O: sgems data structure
%   filename : filename
%
% See also: sgems_read, sgems_write_pointset, sgems_write_grid
%
function O=sgems_write(filename,O)

if nargin<2
    help mfilename
    O=[];
    return
end

MN=1.561792946e+9;
fclose all;
fid=fopen(filename,'w');
if fid<1
    mgstat_verbose(sprintf('%s : could not open %s for writing',mfilename,filename),10);
    O=[];
    return
end


% READ MAGIC NUMBER
if ~isfield(O,'magic_number');O.magic_number=1.561792946e+9;end


fwrite(fid,O.magic_number,'uint32');

% TYPE DEFINITION
if ~isfield(O,'type_def');
    if isfield(O,'nx');
        O.type_def='Cgrid';
    else
        O.type_def='Point_set';
    end
end
if (strcmp(O.type_def,'Point_set')|strcmp(O.type_def,'Cgrid'));
    mgstat_verbose(sprintf('%s : Using type definition %d',mfilename,O.type_def))
else
    mgstat_verbose(sprintf('%s : unsupported type definition (%d)',mfilename,O.type_def),10)
    return
end


if ~isfield(O,'version')
    O.version=100;
end

n_prop=size(O.data,2);
if ~isfield(O,'n_prop')
    O.n_prop=size(O.data,2);
end
if (n_prop)~=(O.n_prop),
    O.n_prop=n_prop;
    mgstat_verbose(sprintf('%s : adjusting n_prop=%d',mfilename,n_prop),10);
end


% TYPE DEF
fwrite_charstar(fid,O.type_def)

% IF POINT SET
if strcmp(O.type_def,'Point_set');
    disp(sprintf('%s : Writing POINTSET data to %s',mfilename,filename))

    % POINT SET NAME
    fwrite_charstar(fid,O.point_set)

    % VERSION
    fwrite(fid,O.version,'int32','b');
    if (O.version<100)
        mgstat_verbose(sprintf('%s : file too old (%s)',mfilename,file))
        return
    end

    % SIZE
    n_data=size(O.data,1);
    if ~isfield(O,'n_data'); O.n_data=n_data;end
    if (n_data)~=(O.n_data),
        O.n_data=n_data;
        mgstat_verbose(sprintf('%s : adjusting n_data=%d',mfilename,n_data),10);
    end

    fwrite(fid,O.n_data,'uint32','b');
    fwrite(fid,O.n_prop,'uint32','b');

    for i=1:O.n_prop
                
        
        if isstr(O.property_name)
            str=O.property_name;
            O=rmfield(O,'property_name');
            O.property_name{i}=str;
        end
        
        try
            property_name=O.property_name{i};
        catch
            property_name=sprintf('D%d',i);
            try;O.property_name{i}=property_name;end
        end
        fwrite_charstar(fid,property_name);
        
    end

    for j=1:O.n_data
        fwrite(fid,O.xyz(j,:),'float32','b');
    end

    for k=1:O.n_prop
        fwrite(fid,O.data(:,k),'float32','b');
        %   for j=1:O.n_data
        %
        %   end
    end
elseif strcmp(O.type_def,'Cgrid');
    disp(sprintf('%s : Writing CARTESIAN GRID (Cgrid) to %s',mfilename,filename))
    
    % POINT SET NAME
    fwrite_charstar(fid,O.grid_name);
    
    % VERSION
    fwrite(fid,O.version,'int32','b');

    % SIZE
    fwrite(fid,[O.nx O.ny O.nz],'uint32','b');
    fwrite(fid,[O.xsize O.ysize O.zsize],'float32','b');
    fwrite(fid,[O.x0 O.y0 O.z0],'float32','b');

    % Properties
    fwrite(fid,O.n_prop,'uint32','b');

    for i=1:O.n_prop
        fwrite_charstar(fid,O.property{i});
    end

    % Data
    for i=1:O.n_prop
        fwrite(fid,O.data(:,i),'float32','b');
    end

    
end

fclose(fid);



function fwrite_charstar(fid,str);
    str_len=length(str)+1;
    str_len = fwrite(fid,str_len,'uint32','b');
    fwrite(fid,str,'char');
    fwrite(fid,0,'char');

