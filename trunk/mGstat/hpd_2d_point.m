% hpd_2d_point : highest posterior density plot from scattered data
%
% Call :
%  [lik,levels,x,y]=hpd_2d_point(x_p,y_p,lik_p,x,y,hpd_levels,corner_type)
%
% See also : hpd_2d
%
% Example :
%  nd=1300;
%  x_p=randn(nd,1)*1;
%  y_p=randn(nd,1)*1;
%  lik_p = abs(peaks(x_p,y_p));
%  subplot(1,3,1);
%  [lik,levels,x,y]=hpd_2d_point(x_p,y_p,lik_p);
%  subplot(1,3,2);
%  [lik,levels,x,y]=hpd_2d_point(x_p,y_p,lik_p,[],[],[.1:.1:1]);
%  subplot(1,3,3);
%  [lik,levels,x,y]=hpd_2d_point(x_p,y_p,lik_p,-1:.1:1,-1:.1:1,[.2 0.5 1.0]);
%
%
function [lik,levels,x,y]=hpd_2d_point(x_p,y_p,lik_p,x,y,hpd_levels,corner_type);

if nargin==0;
    help(mfilename)
    nd=1300;
    x_p=randn(nd,1)*1;
    y_p=randn(nd,1)*1;
    lik_p = abs(peaks(x_p,y_p));

    subplot(1,3,1);
    [lik,levels,x,y]=hpd_2d_point(x_p,y_p,lik_p);
    subplot(1,3,2);
    [lik,levels,x,y]=hpd_2d_point(x_p,y_p,lik_p,[],[],[0.1:.2:1]);
    subplot(1,3,3);
    [lik,levels,x,y]=hpd_2d_point(x_p,y_p,lik_p,-1:.1:1,-1:.1:1,[.2 0.5 1.0]);
    return
end

if nargin<4, x=[]; end
if nargin<5, y=[]; end
if nargin<6, hpd_levels=[.1:.1:1]; end
if nargin<7, corner_type='null'; end
%if nargin<7, corner_type='interp'; end

if isempty(x)
    x=linspace(min(x_p),max(x_p),60);
end
if isempty(y)
    y=linspace(min(y_p),max(y_p),60);
end

nd=length(x_p);
if strcmp(corner_type,'null')
    i=nd+1;x_p(i)=x(1);y_p(i)=y(1);lik_p(i)=0;
    i=i+1;x_p(i)=max(x);y_p(i)=y(1);lik_p(i)=0;
    i=i+1;x_p(i)=max(x);y_p(i)=max(y);lik_p(i)=0;
    i=i+1;x_p(i)=x(1);y_p(i)=max(y);lik_p(i)=0;
else
    i=1;x_p2(i)=x(1);y_p2(i)=y(1);    
    i=i+1;x_p2(i)=max(x);y_p2(i)=y(1);    
    i=i+1;x_p2(i)=max(x);y_p2(i)=max(y);    
    i=i+1;x_p2(i)=x(1);y_p2(i)=max(y);    
    lik_p2=griddata(x_p,y_p,lik_p,x_p2,y_p2,'nearest');
    lik_p=[lik_p(:) ; lik_p2(:)];
    x_p=[x_p(:) ; x_p2(:)];
    y_p=[y_p(:) ; y_p2(:)];
end   


[xx,yy]=meshgrid(x,y);

lik = griddata(x_p,y_p,lik_p,xx,yy,'cubic');

[levels]=hpd_2d(lik,hpd_levels);


[C,h,CF]=contourf(x,y,lik,levels);

%

%colormap(1-gray);
