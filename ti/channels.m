% channels : 2D [250x250] training image
% from Strebelle (2000)
function d=channels(di);
if nargin==0;
    di=1;
end

%% 
d=load('channels.mat');
d=d.channels;

if nargin>0;
    % rescale
    [ny,nx]=size(d);
    x=1:nx;
    y=1:ny;
    [xx,yy]=meshgrid(x,y);
    
    
    x2=1:di:nx;
    y2=1:di:ny;
    [xx2,yy2]=meshgrid(x2,y2);
    

    d = griddata(xx(:),yy(:),d(:),xx2,yy2,'nearest');
end