% progress_txt : console based progress bar
%
% Ex1 : 
%   for i=1:10000;
%     progress_txt(i,10000,'Ciao');
%   end
%
% Ex1 :
%
%   for i=1:10;
%   for j=1:10;
%   for k=1:10;
%     progress_txt([i j k],[10 100 1000],'i','j','k');
%   end
%   end
%   end
%
% TMH/2005, thomas@cultpenguin.com
%
function progress_txt(i,max_it,varargin);
 
  if nargin==0
    help progress_txt
    return;
  end
  
  if nargin<2, max_it=ones(size(i)).*Inf;end
  try
      if isnumeric(varargin{length(varargin)});
          statusbar_ok=varargin{length(varargin)};
      end
  end
  if ~exist('statusbar_ok','var')
      statusbar_ok=0;
  end
  
  
  if (~exist('statusbar.m')==2)
      statusbar_ok=0;
  end

  if (isoctave)
      statusbar_ok=0;
  end

  statusbar_ok=0;
  ncols=length(i);
  
  %
  nchar=45;  
  
  % 
  pc=i./max_it;
  % clear command window
  %if statusbar_ok==0;clc;end 

  for m=1:ncols
    
    try
      txt=varargin{m};
    catch
      txt='';
    end
    
    char_prog='';
    for j=1:nchar
      if j<=(pc(m)*nchar);
        char_prog=[char_prog,'+'];
      else
        char_prog=[char_prog,'-'];
      end
    end
  
    txt=sprintf('%10s %s %3.1f %d/%d',txt,char_prog,100*pc(m),i(m),max_it(m));
    if (statusbar_ok==1)
        if (m==1)
            statusbar(0,txt);
        end
    else
        disp(txt);        
    end
  end