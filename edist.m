% edist : Euclidean distance
%
% Call : 
%   D=edist(p1,p2,transform,isorange)
% 
% p1,p2 : vectors
%
% transform : GSTAT anisotropy and/or range information 
%
% isorange : [0] (default), transform is the usual GSTAT-anisotropy setting 
% isorange : [1] means that transform simply lists the range in
% each dimensions, and that no rotation is performed 

function D=edist(p1,p2,transform,isorange)
  
  
  
  if nargin<4
    isorange=0;
  end
  
  if nargin==1;
    p2=0.*p1;
  end
  
  
  if size(p1,1)==1
    dp=(p1-p2)';
  else
    dp=(p1-p2);
  end
  
  if isorange==1
    % ONLY SACLING, no transformation

    %rescale=transform
    %RescaleMat=eye(length(rescale));
    %for i=1:length(rescale)
    %  RescaleMat(i,i)=rescale(i);
    %end
    %dp=RescaleMat*dp;
    
    if transform==0
      % Do not transfrom since this is likely a nugget
    else
      dp=transform(1).*dp./transform(:);
    end
    D=sqrt(dp'*dp);
    return    
  end
  
  

	
  % 2D COORDINATE TRANSFORMATION
  if (nargin>2)&(length(p1)==2);

    if length(transform)>1
    
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
  end

  % 3D COORDINATE TRANSFORMATION
  if (nargin>2)&(length(p1)==3);
    % NOT YET IMPLEMENTED, SEE GSLIB BOOK
  end


  D=sqrt(dp'*dp);
