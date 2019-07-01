% entropy: Entropy and selfinformation from 1D pd, using a specfic base
%
% Call:
%  [H,I]=entropy(P,base)
%  P: [1,nd] probability df
%  base: [1] base of logartihm (def=2)
%
function [H,I]=entropy(p,base)
if nargin<2
    base=2;
end
i=find(p>0);


%I=-log(p(i)); 
I=- log(p(i))./log(base); 

P=p(i);

H = sum( P.*I );