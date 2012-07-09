% colormap_nan
%
% Replaces all NaN values with a specific color, and rescales the
% colorbar appropriately;
%
%
% example :
% d=peaks(200);
% d(find(d<0))=NaN;
% figure(1);
% im=imagesc(d);
% colormap(hot);
% colormap_nan(im);
% drawnow;
%
% 
% figure(2);
% im=imagesc(d);
% colormap(jet);
% colormap_nan(im,[.2 .9 .1]);
% colorbar;drawnow;
%
%
%
%
function colormap_nan2(im,nancolor,method)

    if nargin<2
        nancolor=[1 1 1];
    end
    
    if nargin<1
        return
    end

    if nargin<3
        method=1;
    end
    
    if length(im)==1
        Cdata=get(im,'Cdata');
    else
        Cdata=im;
    end
    
    %find(isnan(Cdata))=nan_val;
    nanmap=Cdata.*0;
    nanmap(find(isnan(Cdata)))=1;

   
    if method==1
        set(im,'alphadata',1-nanmap)
    else
        
        cax=caxis;
        nan_val=cax(1)-(cax(2)-cax(1));
        Cdata(find(isnan(Cdata)))=nan_val;
        set(im,'Cdata',Cdata);
       
        cmap=colormap;
        nc=size(cmap,1);
        cmap(1,:)=[nancolor]
        colormap(cmap);
        dperc=-2/nc;
        colormap_squeeze([dperc,0]);
        
    end
    return
    
    