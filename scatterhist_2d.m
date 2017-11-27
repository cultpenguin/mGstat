% scatterhist_2d: 2D scatter histogram with 1d marginals.
%
%  scatterhist_2d(x_acc,y_acc)
%  scatterhist_2d(x_acc,y_acc,x,y)
%
function scatterhist_2d(x_acc,y_acc,x,y,plot_1d,gain)
if nargin<3, x=linspace(min(x_acc),max(x_acc),51); end
if nargin<4, y=linspace(min(y_acc),max(y_acc),51); end
if nargin<5, plot_1d=1;end
if nargin<6, gain=1;end
N=length(x_acc);
nx=length(x);dx=x(2)-x(1);
ny=length(y);dy=y(2)-y(1);


x0=x(1);
y0=y(1);
lx=max(x)-min(x);
ly=max(y)-min(y);

[P_post_est,x_arr,y_arr] = hist2(x_acc(:),y_acc(:),x,y);
imagesc(x,y,P_post_est');colormap(1-gray);axis image
xlabel('m_1');ylabel('m_2')
set(gca,'ydir','normal')
ax=axis;
if plot_1d==1;
    hold on
    Px=hist(x_acc,x)/(dx*N);
    Py=hist(y_acc,y)/(dy*N);
    plot(x,y0+zeros(1,nx)+gain*ly.*Px,'-','color',[1 1 1].*.5)
    plot(x0+zeros(1,ny)+gain*lx.*Py,y,'-','color',[1 1 1].*.5)
    hold off
end

axis(ax);