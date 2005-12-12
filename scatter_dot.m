% scatter_dot : A black dot beneith scatter dots 
%
% Call  : 
%   scatter_dot(x,y,MS,v,option)
%
function scatter_dot(x,y,MS,v,option)

if nargin==4
  option='filled';
end

plot(x,y,'k.','MarkerSize',MS+2)
hold on
scatter(x,y,MS,v,option)
hold off