% gaussian_likelihood : computes likelihood 
%
%  [L,logL]=gaussian_likelihood(m,m0,Cm,is_inv);
%  L:likelihood that m is a realization of the Gaussian N(m0,Cm)
%  if is_inv=1, Cm is really inv(Cm);
%
function [L,logL]=gaussian_likelihood(m,m0,Cm,is_inv);

if nargin<4
    is_inv=0;
end

dm=m-m0;dm=dm(:);

if is_inv==1
    logL = (-.5 * dm' * Cm *dm);
else
    logL = (-.5 * dm' * inv(Cm) *dm);
end
L=exp(logL);
