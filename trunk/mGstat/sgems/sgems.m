% sgems : Executes SGeMS on python script
%
% To run an python script through SGeMS run 
%   sgems('name_of_pythin_script.py')
%
% To run SGeMS using a GUI run 
%   sgems 
%
%
% In windows you need to have an environemnt variable set that point to the
% SGeMS installation directory :
% GSTLAPPLIHOME=c:\Program Files\SGeMS
% In addition you may have to add a link to the location of the sgems.exe
% executable below in the source code for sgems.m
%
%
%
% TMH/08/2008
%
function sgems(py_script);

sgems_bin='c:\Program Files\SGeMS\sgems.exe';

if nargin==0;
    system(sgems_bin);
    return
end
if (exist(py_script,'file')~=2)
    mgstat_verbose(sprintf('%s : "%s" does not exist.',mfilename,py_script),-1)
    return 
end
cmd=sprintf('"%s" -s %s',sgems_bin,py_script);
system(cmd);




