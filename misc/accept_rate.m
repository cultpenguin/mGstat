% accept_rate : computes acceptance ratio from array
%
%   [pacc_rate,N,Nav]=accept_rate(iacc,Nav);
%   iacc : indicator array indicating accepts, e.g. iacc= [0 1 1 1 0 0 1 1 ]
%   Nav  : integer, number of iteration over which to average 
%
function [pacc_rate,N,Nav]=accept_rate(iacc,Nav);
if nargin<2
    Nav=100;
end

i2=length(iacc);
i1=i2-Nav;
if i1<1
    i1=1;
    Nav=i2-i1;
end


N=sum(iacc(i1:i2));
pacc_rate=N./Nav;

