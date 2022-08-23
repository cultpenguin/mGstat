% bordley: Probability aggregation
%
% Call: 
%   p_com=bordley(p0,p,w);
% Ex:
%   p0=[.5 .5];
%   p1=[0.2 0.8];
%   p2=[0.4 0.6];
%   p3=[0.55 0.45];
%   w=[.1, .1, 1];
%   p_com=bordley(p0,[p1;p2;p3],w);
%
% See also, comb_cprob
%
function p_com=bordley(p0,p,w);
if nargin<3, w=1;end
[n,dim]=size(p);
if length(w)==1,
    w=ones(1,n).*w;
end

p_ratio=p./repmat(p0,[n,1]);

for i=1:n
    p_ratio(i,:)=p_ratio(i,:).^w(i);
end

p_com= p0.*prod(p_ratio,1);
p_com=p_com./sum(p_com);



