% scatter_dot : A black dot beneith scatter dots 
%
% Call  : 
%   scatter_dot(x,y,MS,v,option)
%
function scatter_dot(x,y,MS,v,option)

if nargin==4
  option='filled';
end

keephold=ishold;

plot(x,y,'k.','MarkerSize',MS+2)
hold on
scatter(x,y,MS,v,option)

if keephold==0
  % only release hold if hold was off initially.
  hold off
end