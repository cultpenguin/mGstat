% watermark : add watermark to figure : watermark(txt);
function ax=watermark(txt);

if nargin==0
  txt='mGstat';
end

ax=axes;
h=0.1;
set(ax,'position',[.01 .01 .5 .1]);
set(ax,'visible','off')
text(h/2,.5,txt)