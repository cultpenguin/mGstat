% colorbar_shift : Adds a colorbar to the current figure, with no reshaping
%
% Before printing to a PS file you may need to set :
% set(gca,'ActivePositionProperty','Position')
%
%
% example : 
% subplot(2,2,1)
% imagesc(peaks)
% subplot(2,2,2)
% imagesc(peaks)
% set(gca,'ActivePositionProperty','Position')
% colorbar_shift;
%
function H=colorbar_shift(shift,a)
  
  if nargin<2
    a=gca;
  end
  if nargin<1
    shift=.01;
  end
  %APP=get(a,'ActivePositionProperty')
  set(a,'ActivePositionProperty','Position')
  
  pos=get(a,'Position');
  H=colorbar;    
  Hpos=get(H,'position');
  
  set(H,'position',[pos(1)+pos(3)+shift Hpos(2) Hpos(3) Hpos(4)])

  %set(a,'ActivePositionProperty',APP)
