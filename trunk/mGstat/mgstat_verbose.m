% mgstat_verbose : list verbose information to the console
%
% Call:
%  mgstat_verbose(txt,verbose)
%
% txt [string] : text to be displayed
% verbose [integer] (def=0) : increase to see more information
%
% 'vlevel' must be set in the mgstat_verbose.m m-file.
%
% All entries with vebose>vlevel are displayed
%

%
% entries with a higher verbose value has a higher chance of being displayed
% that entries with lower verbose values
% verbose [0] : warnings (default)
%         [1] : function names 
%         [2] : subfunction progress
%
%


%
function mgstat_verbose(txt,verbose)
  

  vlevel=0; % SHOW ALL VERBOSE INFO WITH 'VERBOSE' ABOVE 'VLEVEL'
  try
      % GET VERBOSE LEVEL FROM SYSTEM VARIABLE IF SET
      tmp=str2num(getenv('MGSTAT_VERBOSE_LEVEL'));
      if ~isempty(tmp)
          vlevel=tmp;
      end
  end
  
  if nargin==1,
    verbose=0;
  end
 
  
  if (verbose<=vlevel),
  %if (verbose>=vlevel),
    txt1=mfilename;
    disp(sprintf('%s',txt));
  end