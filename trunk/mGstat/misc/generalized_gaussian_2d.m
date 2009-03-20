% 2D generalized Gaussian
%
% Call:
%
%    f = generalized_gaussian_2d(x,x0,sigma,p);
%

function f = generalized_gaussian_2d(x,y,pos0,sigma,p,ang,do_log);

if nargin<3, pos0=[0 0]; end
if nargin<4, sigma=[1]; end
if nargin<5, p=[10]; end
if nargin<6, ang=30; end
if nargin<7, do_log=1; end


% ROTATIION
d=sqrt((x-pos0(1)).^2+(y-pos0(2)).^2);
angle = atan2( (y-pos0(2)) , (x-pos0(1)) );

x_new=pos0(1) + cos( ang*pi/180 + angle ).*d;
y_new=pos0(2) + sin( ang*pi/180 + angle ).*d;


% COMPUTE LIKELIHOOD
if do_log==1;
    f = log (p^(1-1/p) ./ (2*sigma*gamma(1/p))) +   ((-1/p)* abs(x_new-pos0(1)).^p ./ (sigma(1)^p(1)));
else
    f = p^(1-1/p) ./ (2*sigma(1)*gamma(1/p)) * exp((-1/p)* abs(x_new-pos0(1)).^p ./ (sigma^p));
end


% Make linear adjtustment to make 2D Gaussian