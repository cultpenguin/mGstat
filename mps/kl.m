% kl: Kullback�Leibler divergence
% [d]=kl(P,Q)
%

function d=kl(P,Q)
i=(P>0)&(Q>0);


d=sum(P(i).*log(P(i)./Q(i)));
