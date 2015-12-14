% kl: Kullback–Leibler divergence
% [d]=kl(P,Q)
%

function d=kl(P,Q)
i=P>0;


d=sum(P.*log(P./Q));
