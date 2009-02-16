% sgems : Executes SGeMS on python script
%
% To run an python script through SGeMS run 
%   sgems('name_of_python_script.py')
%
% To run SGeMS form the current working directory, using a GUI run 
%   sgems 
%
% The installation directory of SGeMS is set to c:\Program Files\SGeMS
% If it is located otherwise edit this m-file or set the windows environment variable
% GSTLAPPLIHOME to point to the SGeMS installation directory, as e.g. :
% 
% 
%
%
% In windows you need to have an environemnt variable set that point to the
% SGeMS installation directory :
% GSTLAPPLIHOME=c:\Program Files\SGeMS
% In addition you may have to add a link to the location of the sgems.exe
% executable below in the source code for sgems.m
% setenv('GSTLAPPLIHOME','c:\Program Files\SGeMS');

%
%
% TMH/08/2008
%

% 

function sgems(py_script);

use_wine_on_unix=0;


if (isunix==1)
    if (use_wine_on_unix==1);    
        sgems_bin_install='~/.wine/drive_c/Program\ Files/SGeMS/';
        sgems_bin=sprintf('/usr/bin/wine %s/sgems.exe',sgems_bin_install);
    else
        sgems_bin_install='/usr/local/SGeMS';
        sgems_bin=sprintf('%s/sgems.exe',sgems_bin_install);    
    end
    setenv('GSTLAPPLIHOME',sgems_bin_install);
else

    sgems_bin_install='c:\Program Files\SGeMS';
    if (exist('getenv','file')==5)
        if ~isempty(getenv('GSTLAPPLIHOME'))
            sgems_bin_install=getenv('GSTLAPPLIHOME');
        else
            setenv('GSTLAPPLIHOME', sgems_bin_install);
        end
    end
    sgems_bin=[sgems_bin_install,filesep,'sgems.exe'];
    
end

if (exist(sgems_bin,'file')~=2)
    mgstat_verbose(sprintf(['%s : SGEMS BINARY "%s" does not exist.\n' ...
                        'UPDATE %s%ssgems.exe'],mfilename,sgems_bin,mgstat_dir,filesep),10);
    return 
end


if nargin==0;
    mgstat_verbose(sprintf('%s : Running %s',mfilename,sgems_bin),10);
    system(sprintf('"%s" ',sgems_bin));
    keyboard
    return
end
if (exist(py_script,'file')~=2)
    mgstat_verbose(sprintf('%s : "%s" does not exist.',mfilename,py_script),-1)
    return 
end
cmd=sprintf('"%s" -s %s',sgems_bin,py_script);
mgstat_verbose(sprintf('%s : %s',mfilename,cmd));
%system(cmd);




