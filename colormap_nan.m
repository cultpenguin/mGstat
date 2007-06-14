% colormap_nan
%
% Replaces all NaN values with a specific color, and rescales the
% colorbar appropriately;
%
%
% example :
% d=peaks(200);
% d(find(d<0))=NaN;
% figure(1);imagesc(d);
% colormap(hot);
% colormap_nan;
% drawnow;
% pause(2)
%
% 
% figure(2);imagesc(d);
% colormap_nan(jet,[.2 .9 .1]);
% colorbar;drawnow;
% pause(2);
%
% figure(3);imagesc(d);
% colormap_nan(jet(1000),[.2 .9 .1]);
% colorbar
%
%
%
%
function colormap_nan(cmap,nancolor)

    if nargin<2
        nancolor=[1 1 1];
    end
    
    if nargin<1
        cmap=colormap;
    end

    nc=size(cmap,1);
    
   
    
    cmap(1,:)=[nancolor];
    colormap(cmap);
    
    dperc=-1/nc;    
    colormap_squeeze([dperc,0]);

    