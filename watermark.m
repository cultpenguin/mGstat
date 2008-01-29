% watermark : add watermark to figure : watermark(txt,FontSize);
%
% Call
%  watermark(txt);
%  watermark(txt,FontSize);
%  ax=watermark(txt,FontSize,position);
%
function ax=watermark(txt,FontSize,position);

if nargin<2
    FontSize=6;
end

if nargin==0
  txt='SkyTEM';
end

if nargin<3
    position=[.6 .01 .39 .05];
end

ax=axes;
h=0.1;

if position(1)>.5;
    HorizontalAlignment='right';
else
    HorizontalAlignment='left';
end

set(ax,'position',position);
set(ax,'visible','off')
box on
text(.99,.5,txt,'FontSize',FontSize,'HorizontalAlignment',HorizontalAlignment);