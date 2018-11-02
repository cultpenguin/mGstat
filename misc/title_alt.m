% title_alt : Alternate title positioning
%
% Call : 
%    title_alt(string,isub,location,dw,w_out)
%
% title     [str] : title string
% isub      [int] : Number of subplot. 1-->'a)' is prepended to the title
%                                      2-->'b)' is prepended to the title..
%                                      0--> use original string [Default]
% location  [str] : 'NorthWestInside' 
%                   'NorthWestOutside' [Default]       
%                   'NorthEastInside'        
%                   'NorthEastOutside'        
%
% dw        [rea] : distance from edge to label, relative to plot size
%                   [default dw=0.01];
%
% w_out     [rea] : distance from edge to horizontal edge of label, 
%                   when location='*Outsize', relative to plot size.
%                   [default dw=0.2];
%
% 
%
% EXAMPLE : 
%   figure
%   for i=1:5;
%       subplot(2,3,i)
%       imagesc(peaks(i*10))
%       title_alt('Title',i);
%   end
%
%   figure
%   subplot(2,2,1);title_alt('NorthWestInside',i,'NorthWestInside');
%   subplot(2,2,2);title_alt('NorthWestOutside',i,'NorthWestOutside');
%   subplot(2,2,3);title_alt('NorthEastInside',i,'NorthEastInside');
%   subplot(2,2,4);title_alt('NorthEastOutside',i,'NorthEastOutside');
%        
% (C) TMH/2007
%
function title_alt(string,isub,location,dw,w_out)

    if nargin==0
       t1=(get(gca,'title')); 
       string=get(get(gca,'title'),'string'); 
    end

    if nargin<2
        isub=0;
    end
    if nargin<3
        location='NorthWestOutside';
    end
    if nargin<4
        dw=.01;
    end
    if nargin<5
        w_out=.1;
    end
    
    if ischar(string);
        t1=title(string);
    end
        
   
    if isub>0
        set(t1,'string',sprintf('%s) %s',char(96+isub),get(t1,'string')))
%        set(t1,'string','a')
    end
    
    if strcmp(location,'NorthWestInside')==1
        set(t1,'Units','normalized','position',[dw,1-dw,1.005],'VerticalAlignment','top','HorizontalAlignment','Left')
    elseif strcmp(location,'NorthEastInside')==1
        set(t1,'Units','normalized','position',[1-dw,1-dw,1.005],'VerticalAlignment','top','HorizontalAlignment','Right')
    elseif strcmp(location,'NorthWestOutside')==1
        set(t1,'Units','normalized','position',[-w_out,1+dw,1.005],'VerticalAlignment','bottom','HorizontalAlignment','Left')
    elseif strcmp(location,'NorthEastOutside')==1
        set(t1,'Units','normalized','position',[1+w_out,1+dw,1.005],'VerticalAlignment','bottom','HorizontalAlignment','Right')
    end
    

    
    
    
    