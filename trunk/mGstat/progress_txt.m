% progress_txt : console based progress bar
%
% Ex : 
%   for i=1:10000;
%     progressbar_txt(i,10000,'Ciao');
%   end
%
% TMH/2005, thomas@cultpenguin.com
%
function progress_txt(i,max,txt);
  
  if nargin==2, txt=''; end
  
  %
  nchar=45;  
  
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
  disp(sprintf('%s %s %3.1f%% %d/%d',txt,char_prog,100*pc,i,max))