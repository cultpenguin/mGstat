% sgems_read_project : read an SGeMS project (folder) into Matlab
%
% Call :
%    P=sgems_read_project('project.prj');
%
%    P is a matlab structure containing all read information
% 
function P=sgems_read(foldername)

if nargin<1
    help mfilename
    P=[];
    return
end

d=dir(foldername);

for id=1:length(d);
    % DO NOT READ '..' '.' '.cvs' '.svn' '.*'
    if (strcmp(d(id).name(1),'.')==0)
        try
            filename=fullfile(foldername,d(id).name);
            object_name=space2char(d(id).name);
            P.(object_name)=sgems_read(filename);
        catch
            mgstat_verbose(sprintf('Failed to load %s',filename),-1);
        end
    end
end

if ~exist('P','var')
    P.null=[];
end
