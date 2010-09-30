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

n_dim=size(p1,2);

dp=(p1-p2);
if isorange==1
    %mgstat_verbose(sprintf('%s : isorange',mfilename))
    % ONLY SACLING, no transformation
    
    if length(transform)==1;
        transform=ones(1,n_dim).*transform;
    end
    
    if transform==0
        % Do not transfrom since this is likely a nugget
    else
        for j=1:n_dim;
            dp(:,j)=dp(:,j)./transform(j);
        end
        dp=transform(1).*dp;
    end
else
    
    
    % 2D COORDINATE TRANSFORMATION
    if (nargin>2)&(n_dim==2);
        mgstat_verbose(sprintf('%s : 2D coordinate transform'),0);
        if length(transform)>1
            rescale=transform(1:2);
            rotate=transform(3)*pi/180;
            
            dp=dp';
            
            RotMat=[cos(rotate) -sin(rotate);sin(rotate) cos(rotate)];
            RescaleMat=eye(length(rescale));
            RescaleMat(1,1)=1;
            RescaleMat(2,2)=rescale(2);
            
            %dp=RotMat*dp;%dp=RescaleMat*dp;
            dp=RescaleMat*RotMat*dp;
            dp=dp./rescale(2);
            
            dp=dp';
        end
    end
    
    % 3D COORDINATE TRANSFORMATION
    if (nargin>2)&(n_dim==3);
        mgstat_verbose(sprintf('%s : 3D anisotropy not yet implemented',mfilename),-1)
        % NOT YET IMPLEMENTED, SEE GSLIB BOOK
    end
end


if n_dim==1
    D=abs(dp);
else
    D=transpose(sqrt(sum(transpose(dp.^2))));
end
