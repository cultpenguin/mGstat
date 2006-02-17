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
  
  visim_bin='~/bin/visim';

  if (exist('~/bin/visim'))==0
    disp(sprintf('COULD NOT FIND VISIM binary : %s',visim_bin));
    if nargin==0
      disp(sprintf('Using VISIM binary : %s',visim_bin));
      V=[];
      return
    end	
  end

  
  if isstruct(parfile);    
    write_visim(parfile);
    parfile=parfile.parfile;
  end
    
  unix(sprintf('%s %s',visim_bin,parfile));
  V=read_visim(parfile);
  
