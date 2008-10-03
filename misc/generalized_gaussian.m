function f = generalized_gaussian(x,x0,sigma,p);

f = p^(1-1/p) ./ (2*sigma*gamma(1/p)) * exp((-1/p)* abs(x-x0).^p ./ (sigma^p));
