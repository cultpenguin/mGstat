function cplot(x,y,z,cax,MarkerSize,cmap)
% cplot(x,y,z,cax,MarkerSize,cmap)
%
% function to plot (x,y)-dots with colors 
% following the colotmap and caxis
%
% tmh / 11/2003
%
  if exist('cax')==0, cax=caxis; end
  if exist('MarkerSize')==0, MarkerSize=35; end
  if exist('cmap')==0, cmap=colormap; end

  dMS=0.9;
  
  nc=size(cmap,1);
  
  plot(x,y,'k.','MarkerSize',MarkerSize);

  hold on
  
  for i=1:length(x)

    if z(i)>=cax(2); 
      r=cmap(nc,1);g=cmap(nc,2);b=cmap(nc,3);
    elseif  z(i)<=cax(1); 
      r=cmap(1,1);g=cmap(1,2);b=cmap(1,3);
    else
      ic=interp1([cax(1) cax(2)],[1 nc],z(i));
      r=interp1(1:nc,cmap(:,1),ic);
      g=interp1(1:nc,cmap(:,2),ic);
      b=interp1(1:nc,cmap(:,3),ic);
    end

    
    plot(x(i),y(i),'.','MarkerSize',MarkerSize*dMS,'Color',[r g b]);
    
  end
  hold off
  
  
  
  