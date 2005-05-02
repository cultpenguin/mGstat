% edist : Euclidean distance
%
% Call : 
%   D=edist(p1,p2)
% 
% p1,p2 : vectors
%
function D=edist(p1,p2)
  
  if nargin==1;
    p2=0.*p1;
  end
  
  
  if size(p1,1)==1
    dp=p1-p2;
  else
    dp=(p1-p2)';
  end
  D=sqrt(dp*dp');
    