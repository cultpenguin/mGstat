% hist2 : 2D histogram/density of 2D scattered data
%
% Call :
%   [Z,x_arr,y_arr] = hist2(x,y);
%     or
%   [Z,x_arr,y_arr] = hist2(x,y,NX,NY);
%     or 
%   [Z,x_arr,y_arr] = hist2(x,y,x_arr,y_arr);
%
%
% Example : (if run with no argumenst)
%
%    nd=100000;
%    x=randn(nd,1)*1;
%    y=randn(nd,1)*2;
%    [Z,x_arr,y_arr] = hist2(x,y);
%    imagesc(x_arr,y_arr,Z);
%
%
% Inspired by:
% http://blogs.mathworks.com/videos/2010/01/22/advanced-making-a-2d-or-3d-histogram-to-visualize-data-density
%
%
% See also hpd_2d, hpd_2d_point, hist3
%

% Another example...
% [Z,x_arr,y_arr,x,y] = hist2;
% 
% subplot(1,3,1);
% plot(x,y,'k.','MarkerSize',.3);axis image
% subplot(1,3,2);
% pcolor(x_arr,y_arr,Z);axis image;colorbar
% 
% subplot(1,3,3);
% hpd_level=[.2 .5 .8];
% [levels]=hpd_2d(Z,hpd_level)
%  
% contourf(x_arr,y_arr,Z,levels);
% axis image;
% title(sprintf('HPD'))


function [Z,x_arr,y_arr,x,y] = hist2(x,y,x_arr,y_arr);



if nargin==0
    nd=100000;
    x=randn(nd,1)*1;
    y=randn(nd,1)*2;
    

    x=rand(nd,1)*4-2;
    y=rand(nd,1)*4-2;
    L=peaks(x,y);
    L=L-min(L);L=L./max(L);
    r=rand(nd,1);
    
    i_use=find(r>L);
    x=x(i_use);
    y=y(i_use);
    
    
    [Z,x_arr,y_arr] = hist2(x,y);
    imagesc(x_arr,y_arr,Z);
    return
end

if nargin<3, x_arr=20; end
if nargin<4, y_arr=20; end
if length(x_arr)==1,x_arr=linspace(min(x),max(x),x_arr);end
if length(y_arr)==1,y_arr=linspace(min(y),max(y),y_arr);end

nx=length(x_arr);
ny=length(y_arr);


xr = interp1(x_arr,.5:(numel(x_arr)-.5),x,'nearest');
yr = interp1(y_arr,.5:(numel(y_arr)-.5),y,'nearest');

Z = accumarray([xr yr]+.5,1,[nx ny]);




