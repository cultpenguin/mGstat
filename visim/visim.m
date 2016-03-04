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
% Source code for SNESIM can be downloaded here:
% https://github.com/SCRFpublic/snesim-standalone
%
% executable files must be located in $MGSTAT_INSTALL/bin
% The default executable for windows is $MGSTAT_INSTALL/bin/snesim.exe
% The default executable for 64bit linux is $MGSTAT_INSTALL/bin/snesim_glnxa64
% The default executable for 64bit OSX is $MGSTAT_INSTALL/bin/snesim_maci64
%
% OSX notes:
%   * Xocde must be installed
%   * The correct path for gfortran must be set. Usually this can be
%     obtained using setenv('DYLD_LIBRARY_PATH', '/usr/local/bin');
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
    

    % FIRST TRY TO FIND THE snesim BINARY IN THE mGstat/bin/ DIRECTORY
    [p,f,s]=fileparts(which('mgstat_verbose'));
    mgstat_bin_dir=[p,filesep,'bin'];
    if isunix==1
        visim_bin=[mgstat_bin_dir,filesep,'visim_',computer('arch')];
        if ~exist(visim_bin,'file')
            visim_bin=[mgstat_bin_dir,filesep,'visim'];
        end
        
        if ismac
            if isempty(getenv('DYLD_LIBRARY_PATH'))
                disp(sprintf('%s: SETTING DYLD LIBRARY PATH',mfilename))
                setenv('DYLD_LIBRARY_PATH', '/usr/local/bin')
            end
        end
    else
        visim_bin=sprintf('%s\\bin\\visim.exe',p);
    end
    

    if (exist(visim_bin,'file'))==0
        % MANUALLY THE THE PATH TO VISIM
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
    [status,result]=system(sprintf('%s %s',visim_bin,parfile));
else
    [status,result]=system(sprintf('"%s" %s',visim_bin,parfile));
end
V=read_visim(parfile);
V.time=toc;

mgstat_verbose(sprintf('%s : %s',mfilename,result),1);


%fclose all;

