% kl: Kullback�Leibler divergence
% [d]=kl(P,Q)
%

function d=kl(P,Q, base)
if nargin<3, base=2;end

i=(P>0)&(Q>0);
d=sum(P(i).*log(P(i)./Q(i)));
d=sum(P(i).*log(P(i)./Q(i)))./log(base);

if sum((Q==1)|(Q==0))==length(Q)
    d=Inf;
end
if (sum(abs(P-Q)))==0, d=0; end