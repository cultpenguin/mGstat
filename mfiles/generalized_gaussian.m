% generalized Gaussian
%
% Call:
%
%    f = generalized_gaussian(x,x0,sigma,p,do_log);
%

function f = generalized_gaussian(x,x0,sigma,p,do_log);

if nargin<5
    do_log=1;
end




if do_log==1;
    f = log (p^(1-1/p) ./ (2*sigma*gamma(1/p))) +   ((-1/p)* abs(x-x0).^p ./ (sigma^p));
else
    f = p^(1-1/p) ./ (2*sigma*gamma(1/p)) * exp((-1/p)* abs(x-x0).^p ./ (sigma^p));
end
