% edist : Euclidean distance
%
% Call : 
%   D=edist(p1,p2)
% 
% p1,p2 : vectors
%
function D=edist(p1,p2,rescale,rotate)
  
  if nargin==1;
    p2=0.*p1;
  end
  
  
  if size(p1,1)==1
    dp=(p1-p2)';
  else
    dp=(p1-p2);
  end
  
  %  if exist('rotate')==1
  if nargin>=4;
    RotMat=[cos(rotate) -sin(rotate);sin(rotate) cos(rotate)];
    dp=RotMat*dp;
  end
  
  if nargin>=3;
    % if exist('rescale')==1
    RescaleMat=eye(length(rescale));
    for i=1:length(rescale)
      RescaleMat(i,i)=rescale(i);
    end
    %dpp=dp;
    dp=RescaleMat*dp;
    %disp(sprintf('',dpp,dp)
  end
  
%  dp=RescaleMat*RotMat*dp;
  
  D=sqrt(dp'*dp);
    