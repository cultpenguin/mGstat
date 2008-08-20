% mgstat_verbose : list verbose information to the console
%
% verbose [0] : everything
%         [10] : function progress 
%         [11] : subfunction progress
%
function mgstat_verbose(txt,verbose)
  if nargin==1,
    verbose=0;
  end
 
  vlevel=10; % SHOW ALL VERBOSE INFO ABOVE 1
  
  if (verbose>=vlevel),
    txt1=mfilename;
    disp(sprintf('%s',txt));
  end