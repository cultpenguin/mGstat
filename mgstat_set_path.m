% mgstat_set_path : set path to all mGstat 
%
%   set path to : 
%     mGstat_Install_Dir/gstat
%     mGstat_Install_Dir/snesim
%     mGstat_Install_Dir/visim
%     mGstat_Install_Dir/sgems
%     mGstat_Install_Dir/misc
%

function mgstat_set_path;
ip=0;
ip=ip+1;P{ip}='';
ip=ip+1;P{ip}='gstat';
ip=ip+1;P{ip}='snesim';
ip=ip+1;P{ip}='visim';
ip=ip+1;P{ip}='sgems';
ip=ip+1;P{ip}='mp';
ip=ip+1;P{ip}='misc';

for ip=1:length(P);
    pa=[mgstat_dir,filesep,P{ip}];
    mgstat_verbose(sprintf('%s : Adding path to ''%s''',mfilename,pa),0)
    addpath(pa);
end

succ=savepath;
if succ==0
    mgstat_verbose(sprintf('%s : saved path for later session',mfilename),0)
else
    mgstat_verbose(sprintf('%s : COULD NOT SAVE PATH for later session',mfilename),0)
end
