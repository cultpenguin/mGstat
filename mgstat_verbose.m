% mgstat_verbose : list versbose information to the console
%
% verbose [0] : everything
%         [10] : function progress 
%         [11] : subfunction progress
%
function mgstat_verbose(txt,verbose)
  if nargin==1,
    verbose=10;
  end
  
  
  
  vlevel=2; % SHOW ALL VERBOSE INFO ABOVE 1
  
  if (verbose<=vlevel),
    disp(sprintf('mGstat : %s',txt));
  end