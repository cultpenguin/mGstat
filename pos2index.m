% [ix,iy]=pos2index(xpos,ypos,x,y);
function [ix,iy]=pos2index(xpos,ypos,x,y);
%  for i=1:length(xpos)
%    ix(i)=find(xpos(i)==x);
%  end
%  for i=1:length(ypos)
%    iy(i)=find(ypos(i)==y);
%  end


  for i=1:length(xpos)
    ix(i)=find(round(1000*xpos(i))==round(1000*x));
  end
  for i=1:length(ypos)
    iy(i)=find(round(1000*ypos(i))==round(1000*y));
  end
