function sgems(py_script);

sgems_bin='c:\Program Files\SGeMS\sgems.exe';

if nargin==0;
    system(sgems_bin);
    return
end

cmd=sprintf('"%s" -s %s',sgems_bin,py_script)
system(cmd);




