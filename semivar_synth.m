% semivar_synth : synthethic semivariogram
function [sv,d]=semivar_synth(V,d);
  
  if nargin==0,
    V='5 Nug(0) + 1 Sph(5)';
    d=[0:1:100];
  end
  
  if nargin==1
    d=[0:1:100];
  end
  
  if isstr(V)
    V=deformat_variogram(V);
  end

  sv=zeros(size(d));
  
  for iv=1:length(V),
    keyboard
   
    synthetic_variogram(V(iv).type,V(iv).par1,V(iv).par2);
    
  end
  
function synthetic_variogram(type,v1,v2)
  if strmatch(type,'Nug')
    disp('Nug')
    %% SEE GSTAT MANUAL FOR TYPES....
  elseif strmatch(type,'Sph')
    disp('Sph')
  elseif strmatch(type,'Gauss')
  else
    mgstat_verbose(sprintf('%s : ''%s'' type is not recognized',mfilename,type));
  end
  