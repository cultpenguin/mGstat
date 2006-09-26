% visim : runs visim with parameter file or visim structure
%
% Call : 
%   visim('visim.par');
%
%   V=read_visim('visim.par');
%   V.nsim=10;
%   visim(V)
%
function V=visim(parfile);
  

  % FIRST TRY TO FIND THE VISIM BINARY IN THE mGstat/bin/ DIRECTORY
  [p,f,s]=fileparts(which('visim'));
  if isunix
    visim_bin=sprintf('%s/../bin/visim',p);
  else
    visim_bin=sprintf('%s\\..\\bin\\visim.exe',p);
  end

  if (exist(visim_bin))==0
    if isunix
      % TRY TO LOCATE visim IN THE UNIX PATH
      [s,visim_bin]=system('which visim');      
    end
  end
  
  if (exist(visim_bin))==0
    % MANUALLU THE THE PATH TO VISIM
    visim_bin='~/bin/visim';
  end

  
  
  if (exist(visim_bin))==0
    disp(sprintf('COULD NOT FIND VISIM binary : %s',visim_bin));
  end

  if ((nargin==0)&(nargout==0))
    disp(sprintf('Using VISIM binary : %s',visim_bin));
    return
  end	
  
  if isstruct(parfile);    
    write_visim(parfile);
    parfile=parfile.parfile;
  end
  tic
  unix(sprintf('%s %s',visim_bin,parfile));
  V=read_visim(parfile);
  V.time=toc;
  
  fclose all;
  
  