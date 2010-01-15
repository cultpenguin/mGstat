% visim : runs visim with parameter file or visim structure
%
% Call :
%   visim('visim.par');
%
%   V=read_visim('visim.par');
%   V.nsim=10;
%   visim(V)
%
%
% To use an alternative visim exe file use :
%   visim('visim.par','visim_801_801_1_1');
%   First the local folder is searched for an exe file with the proposed
%   name, then the mGstat/bin folder is searhed
%
%
% See also: visim_error_sim, visim_cholesky
%
function V=visim(parfile,visim_bin)

p=mgstat_dir;

visim_bin_ok=0;
if nargin==2
    if exist(visim_bin)
        visim_bin_ok=1;
    elseif exist([pwd,filesep,visim_bin])
        visim_bin=[pwd,filesep,visim_bin]
        visim_bin_ok=1;
    elseif exist([pwd,filesep,visim_bin,'.exe'])
        visim_bin=[pwd,filesep,visim_bin];
        visim_bin_ok=1;
    elseif exist([mgstat_dir,filesep,'bin',filesep,visim_bin])
        visim_bin=[mgstat_dir,filesep,'bin',filesep,visim_bin];
        visim_bin_ok=1;
    elseif exist([mgstat_dir,filesep,'bin',filesep,visim_bin,'.exe'])
   
        visim_bin=[mgstat_dir,filesep,'bin',filesep,visim_bin,'.exe'];
        visim_bin_ok=1;
    end
   
    if visim_bin_ok==0
        mgstat_verbose(sprintf('%s : Could not find proper VISIM exe :  %s',mfilename,visim_bin),10)
        return
    end
    
end

if visim_bin_ok==1
    mgstat_verbose(sprintf('%s : using VISIM exe : %s',mfilename,visim_bin),1)
else
    
    
    % FIRST TRY TO FIND THE VISIM BINARY IN THE mGstat/bin/ DIRECTORY
    
    
    [p,f,s]=fileparts(which('visim'));
    if isunix
        visim_bin=sprintf('%s/../bin/visim',p);
    else
        visim_bin=sprintf('%s\\..\\bin\\visim.exe',p);
    end
    
    if (exist(visim_bin,'file'))==0
        if isunix
            % TRY TO LOCATE visim IN THE UNIX PATH
            [s,visim_bin]=system('which visim');
        end
    end
    
    
    if (exist(visim_bin,'file'))==0
        % MANUALLU THE THE PATH TO VISIM
        visim_bin=[mgstat_dir,filesep,'bin',filesep,'visim'];
    end
    
    if (exist(visim_bin,'file'))==0
        disp(sprintf('COULD NOT FIND VISIM binary : %s',visim_bin));
        visim_bin='';
    end
    
end

%if ((nargin==0)&&(nargout==0))
if ((nargin==0))
  V=visim_bin;
  disp(sprintf('Using VISIM binary : %s',visim_bin));
  return
end


tic

if (isstruct(parfile));
    if isfield(parfile,'do_cholesky');
        if parfile.do_cholesky==1;
            V=visim_cholesky(parfile);
            V.time=toc;
            return
        end
    end
    if isfield(parfile,'do_error_sim');
        do_error_sim=parfile.do_error_sim;
        if parfile.do_error_sim==1;
            parfile.do_cholesky=0;            
            parfile=rmfield(parfile,'do_error_sim');
            V=visim_error_sim(parfile);
            V.do_error_sim=do_error_sim;
            V.time=toc;
            return
        end
    end
    
    write_visim(parfile);
    parfile=parfile.parfile;
    
end

if isunix==1
    unix(sprintf('%s %s',visim_bin,parfile));
else
    dos(sprintf('"%s" %s',visim_bin,parfile));
end
V=read_visim(parfile);
V.time=toc;

%fclose all;

