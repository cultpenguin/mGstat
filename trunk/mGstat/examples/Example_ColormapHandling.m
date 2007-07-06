% Example : Example_ColormapHandling
%
% Matlab is bad at handling Nan values in image plots
%
%

n=30;
data=peaks(n);
x=1:1:n;
y=x;


%%%%% CONVENTIONAL PLOT
% SET SOME VALUES TO BE NaN :
figure
data(find(data<-2))=NaN;
imagesc(x,y,data)
colorbar


%%%%%% TRYING TO CHANGE COLORMAP
figure
imagesc(x,y,data)
% GET CURRENT COLORMAP
cmap=colormap;
% SET FIRST COLOR OF COLORMAP TO WHITE
cmap(1,:)=[1 1 1];
% APPLY COLORMAP
colormap(cmap)
colorbar


%%%%%% USING ALPHA MAPS
% THE BEST APPROACH BUT YOU MAY FAIL OF OPENGL DOES NOT WORK
%im=imagesc(x,y,data)
%amap=1-isnan(data)
%set(im,'AlphaData',amap)