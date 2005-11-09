% progress_txt : console based progress bar
%
%
%
function progress_txt(i,max,txt);
  
  if nargin==2, txt=''; end
  
  %
  nchar=25;  
  
  % 
  pc=i/max;
  
  % clear command window
  clc; 

  
  char_prog='';
  for j=1:nchar
    if j<=(pc*nchar);
      char_prog=[char_prog,'#'];
    else
      char_prog=[char_prog,'_'];
    end
  end
  disp(sprintf('%s %s %3.1f%%',txt,char_prog,100*pc))