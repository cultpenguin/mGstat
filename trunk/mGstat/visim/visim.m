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
  
  visim='/home/tmh/bin/visim';
  
  if isstruct(parfile);    
    write_visim(parfile);
    parfile=parfile.parfile;
  end
    
  unix(sprintf('%s %s',visim,parfile));
  V=read_visim(parfile);
  