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

function [sgems_bin,cmd]=sgems(py_script,use_wine_on_unix);

if nargin<2
    use_wine_on_unix=1;
end


if (isunix==1)
    if (use_wine_on_unix==1);    
        sgems_bin_install='c:\\Program Files\\SGeMS\\';
        sgems_bin=sprintf('wine "%ssgems.exe"',sgems_bin_install);
    else
        sgems_bin_install='/usr/local/SGeMS';
        sgems_bin=sprintf('%s/sgems.exe',sgems_bin_install);    
    end
    setenv('GSTLAPPLIHOME',sgems_bin_install);
else
    sgems_bin_install='c:\Program Files\SGeMS';
    if (exist('getenv')==5)
        if ~isempty(getenv('GSTLAPPLIHOME'))
            sgems_bin_install=getenv('GSTLAPPLIHOME');
        else
            setenv('GSTLAPPLIHOME', sgems_bin_install);
        end
    end
    sgems_bin=[sgems_bin_install,filesep,'sgems.exe'];
end

if (~isunix)&(exist(sgems_bin,'file')~=2)
    mgstat_verbose(sprintf(['%s : SGEMS BINARY "%s" does not exist.\n' ...
                        'UPDATE %s%ssgems.exe'],mfilename,sgems_bin,mgstat_dir,filesep),-10);
end

if nargin==0;
    if ((use_wine_on_unix==1)&(isunix))
	txt=sprintf('%s : using WINE to run SGeMS binary file %s',mfilename,sgems_bin);
    else	
	txt=sprintf('%s : using SGeMS binary file %s',mfilename,sgems_bin);
    end
    mgstat_verbose(txt,-1);
    return
end

if nargin==0;
    mgstat_verbose(sprintf('%s : Running %s',mfilename,sgems_bin),10);
    system(sprintf('"%s" &',sgems_bin));
    return
end

if (exist(py_script,'file')~=2)
    mgstat_verbose(sprintf('%s : "%s" does not exist.',mfilename,py_script),-1)
    return 
end

if ((use_wine_on_unix==1)&(isunix))
    cmd=sprintf('%s "-s z:%s%s%s"',sgems_bin,space2char(pwd,'\\\','/'),'\\',py_script);
else
    cmd=sprintf('"%s" -s %s',sgems_bin,py_script);
end
mgstat_verbose(sprintf('%s : %s',mfilename,cmd),-1);
%system(cmd);




