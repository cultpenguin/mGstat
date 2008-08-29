% snesim : runs snesim with parameter file or snesim structure
%
% Call : 
%   snesim('snesim.par');
%
%   V=read_snesim('snesim.par');
%   V.nsim=10;
%   snesim(V)
%
function V=snesim(parfile);
  

  % FIRST TRY TO FIND THE snesim BINARY IN THE mGstat/bin/ DIRECTORY
  [p,f,s]=fileparts(which('snesim'));
  if isunix
    snesim_bin=[mgstat_dir,filesep,'bin',filesep,'snesim'];
  else
    snesim_bin=[mgstat_dir,filesep,'bin',filesep,'snesim.exe'];
  end

  if (exist(snesim_bin,'file'))==0
    if isunix
      % TRY TO LOCATE snesim IN THE UNIX PATH
      [s,snesim_bin]=system('which snesim');      
    end
  end

 % TO MANUALqLY SET THE PATH TO snesim PUT IT HERE :
 % snesim_bin='/scratch/tmh/RESEARCH/PROGRAMMING/GSLIB/snesim/snesim';

  if (exist(snesim_bin,'file'))==0
    % MANUALLU THE THE PATH TO snesim
  end

 

  
  
  if (exist(snesim_bin,'file'))==0
    disp(sprintf('COULD NOT FIND snesim binary : %s',snesim_bin));
  end

  if ((nargin==0)&&(nargout==0))
    disp(sprintf('Using snesim binary : %s',snesim_bin));
    return
  end	
  
  if isstruct(parfile);    
    write_snesim(parfile);
    parfile=parfile.parfile;
  end
  tic
    
  %unix(space2char(sprintf('%s %s',snesim_bin,parfile),'\\ '));
  if isunix==1
      unix(sprintf('%s < %s',snesim_bin,parfile));
  else
      dos(sprintf('"%s" < %s',snesim_bin,parfile));
  end
  V=read_snesim(parfile);
  V.time=toc;
  
  fclose all;
  
  