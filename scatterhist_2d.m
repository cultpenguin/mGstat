% scatterhist_2d: 2D scatter histogram with 1d marginals.
%
%  scatterhist_2d(x_sample,y_sample);
%  handles = scatterhist_2d(x_sample,y_sample,x_arr,y_arr);
%
%  % example:
%  x_sample = rand(1,12000);
%  y_sample = randn(1,12000);
%  
%  subplot(1,2,1);
%  scatterhist_2d(x_sample,y_sample);
%  subplot(1,2,2);
%  x_arr = linspace(-.1,1.1,31);
%  y_arr = linspace(-5,5,31);
%  scatterhist_2d(x_sample,y_sample,x_arr,y_arr);
%
% TMH/2017
% 
function [h,x,y]=scatterhist_2d(x_acc,y_acc,x,y,plot_1d,gain,linecolor)
if nargin<3, x=linspace(min(x_acc),max(x_acc),51); end
if nargin<4, y=linspace(min(y_acc),max(y_acc),51); end
if nargin<5, plot_1d=1;end
if nargin<6, gain=.8;end
if nargin<7, linecolor=[1 0 0];end
N=length(x_acc);
nx=length(x);dx=x(2)-x(1);
ny=length(y);dy=y(2)-y(1);


x0=x(1);
y0=y(1);
lx=max(x)-min(x);
ly=max(y)-min(y);

%[P_post_est,x_arr,y_arr] = hist2(x_acc(:),y_acc(:),x,y);
%h=imagesc(x,y,P_post_est');colormap(1-gray);axis image

P=histcounts2(x_acc(:),y_acc(:),x,y);
x_c=(x(2:end)+x(1:end-1))/2;
y_c=(y(2:end)+y(1:end-1))/2;
h(1)=imagesc(x_c,y_c,P');

xlabel('m_1');ylabel('m_2')
set(gca,'ydir','normal')
ax=axis;
if plot_1d==1;
    hold on
    Px=hist(x_acc,x)/(dx*N);
    Py=hist(y_acc,y)/(dy*N);
    h(2)=plot(x,y0+zeros(1,nx)+gain*ly.*Px,'-','color',linecolor);
    h(3)=plot(x0+zeros(1,ny)+gain*lx.*Py,y,'-','color',linecolor);
    hold off
end

axis(ax);
axis square;