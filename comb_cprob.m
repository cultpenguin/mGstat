% comb_cprob : PDF combination using permancne of ratios
%
% Call : 
%  pAgBC=comb_cprob(pA,pAgB,pAgC)
%
%
% pA    : Prob(A)
% pAgB  : Prob(A|B)
% pAgC  : Prob(A|C)
% pAgBC : Prob(A|B,C)
%
% Combination of conditional probabilities 
% based on permanence of updating ratios.
%
% Journel, An Alternative to Traditional Data Independence
% Hypotheses, Math Geol(34), 2002
% 
%
function pAgBC=comb_cprob(pA,pAgB,pAgC)
  
  a = (1-pA)./pA;
  
  b=(1-pAgB)./pAgB;
  c=(1-pAgC)./pAgC;
  
  pAgBC = a./(a+b.*c);
  