% comb_cprob_ind : Combination of two independent conditional PDF
%
% Call :
%    pAgBC=comb_cprob_ind(pA,pAgB,pAgC)
%
% pA    : Prob(A)
% pAgB  : Prob(A|B)
% pAgC  : Prob(A|C)
% pAgBC : Prob(A|B,C)
%
% TMH/2005
%
function pAgBC=comb_cprob_ind(pA,pAgB,pAgC)
  pAgBC = pAgB.*pAgC./pA;
  
  