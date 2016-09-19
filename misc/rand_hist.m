function [val,prob]=rand_hist(H,N)

% Call: function val=rand_hist(H,N)
% Draws a random value from the distribution
% defined by the histogram H.
% H is the histogram
% Hid ids related to the bins of the histogram
% N is the size of the sample

if nargin==1
    N=1;
end

val=zeros(1,N);
for i=1:N
    cdf=cumsum(H);
    cdf=cdf/max(cdf);
    r=rand;
    id=find(cdf>r,1);
    val(i)=id;
end
if nargout>1
    if id>1
        prob=cdf(id)-cdf(id-1);
    else
        prob=cdf(1);
    end
end