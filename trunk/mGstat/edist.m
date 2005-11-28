% edist : Euclidean distance
%
% Call : 
%   D=edist(p1,p2)
% 
% p1,p2 : vectors
%
function D=edist(p1,p2,transform)
  
  if nargin==1;
    p2=0.*p1;
  end
  
  
  if size(p1,1)==1
    dp=(p1-p2)';
  else
    dp=(p1-p2);
  end
  

	
  % 2D COORDINATE TRANSFORMATION
  if (nargin>2)&(length(p1)==2);
  
    rescale=transform(1:2);
  	rotate=transform(3);
  
    RotMat=[cos(rotate) -sin(rotate);sin(rotate) cos(rotate)];
    dp=RotMat*dp;
    
	RescaleMat=eye(length(rescale));
    for i=1:length(rescale)
      RescaleMat(i,i)=rescale(i);
    end
    dp=RescaleMat*dp;

  end

  % 3D COORDINATE TRANSFORMATION
  if (nargin>2)&(length(p1)==3);
    % NOT YET IMPLEMENTED, SEE GSLIB BOOK
  end


  D=sqrt(dp'*dp);
