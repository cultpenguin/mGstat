% gstat_binary : returns the path to the binary gstat
%
% Call :
%    gstat_bin = gstat_binary;
%
function gstat=gstat_binary;

% YOU CAN EITHER SPECIFY THE PATH TO GSTAT HERE BELOW
% gstat='/home/tmh/bin/gstat-2.4.0';
% gstat='/home/tmh/bin/gstat-2.4.3/src/gstat';
% gstat='/home/tmh/RESEARCH/PROGRAMMING/mGstat/gstat/gstat';
% gstat='d:\thomas\Programming\mGstat\gstat.exe';
gstat='';

% IF THE gstat VARAIABLE IS LEFT EMPTY(DEFAULT)
% IT WILL BE LOCATED ON YOUR SYSTEM IF THE
% GSTAT EXECUTABLE IS SOMEWEHRE IN THE PATH


%% LOCATE GSTAT ON SYSTEM
if isempty(gstat)
    if isunix
        [s,w]=system('which gstat');
        
        if ~isempty(w),
            gstat=w(1:length(w)-1);
        end
    else
        gstat='gstat.exe';
    end
    
end
if ~exist(gstat,'file'),
    gstat='';
end


%% LOCATE GSTAT IN mGstat DISTRIBUTION
if isempty(gstat)
    p=mgstat_dir;
    if isunix
        gstat=sprintf('%s%sbin%sgstat',p,filesep,filesep);
        % IF NOT FOUND AND ON MAC MAKE USE OF PRECOMPILED GSTAT FOR MAC
        if ((~exist(gstat,'file'))&ismac)
            gstat=sprintf('%s%sbin%sgstat_mac_g3',p,filesep,filesep);
        end
    else
        gstat=sprintf('%s%sbin%sgstat.exe',p,filesep,filesep);
    end
end
if ~exist(gstat,'file'),
    gstat='';
else
    gstat=which(gstat);
end


if isempty(gstat)
    mgstat_verbose('------------------------------------------------------------',-1);
    mgstat_verbose('FATAL ERROR !!! --------------------------------------------',-1);
    mgstat_verbose('COULD NOT FIND GSTAT EXECUTABLE ',-1);
    mgstat_verbose('Please put a copy of a compiled ''gstat'' somewhere in your system path',-1);
    mgstat_verbose(sprintf('or in the folder %s%sbin',mgstat_dir,filesep),-1);
    mgstat_verbose('------------------------------------------------------------',-1);
    gstat='';
    return;
end

