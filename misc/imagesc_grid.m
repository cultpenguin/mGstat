% imagesc_grid(x,y,D,col,lw);
% 
% imagesc, with gridded lines around cells
%
% Example:; 
%    imagesc_grid(peaks);
%
function h=imagesc_grid(x,y,D,col,lw);
if nargin==1;
    D=x;
    col=[.5, .5, .5];
    lw=.2;
    x=1:size(D,2);
    y=1:size(D,1);
end

if nargin==2;
    D=x;
    col=y;
    lw=.2;
    x=1:size(D,2);
    y=1:size(D,1);
end


h=imagesc(x,y,D);
dx=x(2)-x(1);
dy=y(2)-y(1);

xx=[(x(1)-1):dx:x(end)]+dx/2;
yy=[(y(1)-1):dy:y(end)]+dy/2;
    
hold on
for ix=xx
    plot([1 1].*ix,[yy(1) yy(end)],'k-','color',col,'linewidth',lw)
end
for iy=yy
    plot([xx(1) xx(end)],[1 1].*iy,'k-','color',col,'linewidth',lw)
end
hold off

