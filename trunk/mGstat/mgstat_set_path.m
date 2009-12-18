% mgstat_set_path : set path to all mGstat 
%
% 
%
function mgstat_set_path;
ip=0;
ip=ip+1;P{ip}='';
ip=ip+1;P{ip}='snesim';
ip=ip+1;P{ip}='visim';
ip=ip+1;P{ip}='sgems';
ip=ip+1;P{ip}='fast';
ip=ip+1;P{ip}='misc';

for ip=1:length(P);
    pa=[mgstat_dir,filesep,P{ip}];
    mgstat_verbose(sprintf('%s : Adding path to ''%s''',mfilename,pa),10)
    addpath(pa);
end

succ=savepath;
if succ==0
    mgstat_verbose(sprintf('%s : saved path for later session',mfilename),10)
else
    mgstat_verbose(sprintf('%s : COULD NOT SAVE PATH for later session',mfilename),10)
end
