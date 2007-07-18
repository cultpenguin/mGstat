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

  if (exist(visim_bin,'file'))==0
    if isunix
      % TRY TO LOCATE visim IN THE UNIX PATH
      [s,visim_bin]=system('which visim');      
    end
  end

 % TO MANUALqLY SET THE PATH TO VISIM PUT IT HERE :
  % visim_bin='/scratch/tmh/RESEARCH/PROGRAMMING/GSLIV/visim/visim_10_2000';
  % visim_bin='/scratch/tmh/RESEARCH/PROGRAMMING/GSLIV/visim/visim_100_2000';
  % visim_bin='/scratch/tmh/RESEARCH/PROGRAMMING/GSLIV/visim/visim_400_400';

  if (exist(visim_bin,'file'))==0
    % MANUALLU THE THE PATH TO VISIM
    visim_bin='~/bin/visim';
    visim_bin='/scratch/tmh/RESEARCH/PROGRAMMING/GSLIV/visim/visim_10_2000';
    visim_bin='/scratch/tmh/RESEARCH/PROGRAMMING/GSLIV/visim/visim_100_2000';
    visim_bin='/scratch/tmh/RESEARCH/PROGRAMMING/GSLIV/visim/visim_400_400';
  end

 

  
  
  if (exist(visim_bin,'file'))==0
    disp(sprintf('COULD NOT FIND VISIM binary : %s',visim_bin));
  end

  if ((nargin==0)&&(nargout==0))
    disp(sprintf('Using VISIM binary : %s',visim_bin));
    return
  end	
  
  if isstruct(parfile);    
    write_visim(parfile);
    parfile=parfile.parfile;
  end
  tic
    
  %unix(space2char(sprintf('%s %s',visim_bin,parfile),'\\ '));
  if isunix==1
      unix(sprintf('%s %s',visim_bin,parfile));
  else
      dos(sprintf('"%s" %s',visim_bin,parfile));
  end
  V=read_visim(parfile);
  V.time=toc;
  
  fclose all;
  
  