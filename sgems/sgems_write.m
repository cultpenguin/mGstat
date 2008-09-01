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
if ~isfield(O,'type_def');O.type_def=10;end
if ~isfield(O,'type_def_string');
    if O.type_def==10;
        O.type_def_string='Point_set';
    elseif O.type_def==6
        O.type_def_string='Grid_set'; %% CHECK SGEMS SOURCE CODE
        
        mgstat_verbos(sprintf('%s : unsupported type definition (%d)',mfilename,O.type_def))
    else
        mgstat_verbos(sprintf('%s : unsupported type definition (%d)',mfilename,O.type_def))
    end
end
    
fwrite(fid,O.type_def,'uint32',0,'b');
fwrite(fid,[O.type_def_string],'char');
fwrite(fid,0,'char');

% IF POINT SET
if O.type_def==10
    disp(sprintf('%s : Writing POINTSET data to %s',mfilename,filename))

    % POINT NAME
    if ~isfield(O,'point_set_name_size');
        O.point_set_name_size=length(O.point_set_name);
    end
    fwrite(fid,O.point_set_name_size,'uint32',0,'b');
    fwrite(fid,O.point_set_name,'char');

    % VERSION
    if ~isfield(O,'version')
        O.version=100;
    end
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

    n_prop=size(O.data,2);
    if (n_prop)~=(O.n_prop),
        O.n_prop=n_prop;
        mgstat_verbose(sprintf('%s : adjusting n_prop=%d',mfilename,n_prop),10);
    end


    fwrite(fid,O.n_data,'uint32','b');
    fwrite(fid,O.n_prop,'uint32','b');


    for i=1:O.n_prop

        try
            O.P{i};
        catch
            O.P{i}.null='';
        end

        if ~isfield(O.P{i},'property_name')
            O.P{i}.property_name=sprintf('D%d',i);
        end
        if ~isfield(O.P{i},'property_name_size')
            O.P{i}.property_name_size=length(O.P{i}.property_name);
        end

        if    (O.P{i}.property_name_size)~=(length(O.P{i}.property_name))
            mgstat_verbose(sprintf('%s : adjusting property name length',mfilename),10);
            O.P{i}.property_name_size=length(O.P{i}.property_name);
        end
        fwrite(fid,O.P{i}.property_name_size,'uint32','b');
        fwrite(fid,O.P{i}.property_name,'char');
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
end

fclose(fid);
