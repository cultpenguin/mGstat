% colorbar_shift : Adds a colorbar to the current figure, with no reshaping
% of figure. (usefil when using subplots);
%
% example : 
% subplot(2,2,1)
% imagesc(peaks)
% subplot(2,2,2)
% imagesc(peaks)
% colorbar_shift;
%
% Makes use of: plotboxpos 
%
% Thomas Mejer Hansen, 2008,2014
%
function [hb]=colorbar_shift(shift,ax)
    
if nargin<2
    ax=gca;
end
if nargin<1
    shift=.1;
end

% get position of visible axes
axPos=plotboxpos;

% set positions of colorbar 
wx=axPos(3);
x1=axPos(1)+axPos(3)+shift*axPos(3);
cbPos=[x1,axPos(2),axPos(3)/10,axPos(4)];

% add colorbar
hb = colorbar('position',cbPos);  
