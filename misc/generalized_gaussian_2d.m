% 2D generalized Gaussian
%
% Call:
%
%    generalized_gaussian_2d(x,y,pos0,sigma,p,ang,do_log);
%
% Example
%
%  x= [-10:.1:10];
%  y= [-11:.1:11];
%  pos_center = [5 0];
%  sigma = [8 3];
%  p = 4;
%  ang =30;
%  [f,x,y] = generalized_gaussian_2d(x,y,pos_center,sigma,p,ang);
%  imagesc(x,y,f);
%  axis image;
%  colorbar
%

function [f,x,y] = generalized_gaussian_2d(x,y,pos0,sigma,p,ang,do_log);
if nargin==0
     x=-10:.1:10;
     y=-10:.2:10;
end
if nargin<3, pos0=[0 0]; end
if nargin<4, sigma=[1 1]; end
if length(sigma)==1;
    sigma(2)=sigma(1);
end
if nargin<5, p=[2]; end
if nargin<6, ang=0; end
if nargin<7, do_log=0; end
[xx,yy]=meshgrid(x,y);


% ROTATIION
rang=ang*pi/180;
R = [cos(rang) -sin(rang) ; sin(rang) cos(rang) ];
pos=[xx(:),yy(:)]*R;

d=sqrt( ((pos(:,1)-pos0(1))./sigma(1)).^2+((pos(:,2)-pos0(2))./sigma(2)).^2);

% COMPUTE LIKELIHOOD
if do_log==1;
    f = log (p^(1-1/p) ./ (2*gamma(1/p))) +   ((-1/p)* abs(d).^p ./ (1^p(1)));
else
    f = p^(1-1/p) ./ (2*gamma(1/p)) * exp((-1/p)* abs(d).^p ./ (1^p));
end
f=reshape(f,length(y),length(x));

if nargin<0
    imagesc(f)
end
