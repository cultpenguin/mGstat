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

function [D,dp]=edist(p1,p2,transform,isorange)

if nargin<4
    isorange=0;
end

if nargin==1;
    p2=0.*p1;
end

n_dim=size(p1,2);

dp=(p2-p1);
if isorange==1
    %mgstat_verbose(sprintf('%s : isorange',mfilename))
    % ONLY SCCALING,edit no transformation
    
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
        %mgstat_verbose(sprintf('%s : 2D coordinate transform'),0);
        if length(transform)>1
            
            if length(transform)==6
                t=transform;
                transform=zeros(1,3);
                transform(1:3)=t([1,2,5]);
            end
            rescale=transform([1,3]);
            r1=rescale(1);
            r2=rescale(1)*rescale(2);
            rotate=transform(2)*pi/180;
            
            % ROTATE
            RotMat=[cos(rotate) -sin(rotate);sin(rotate) cos(rotate)];
            dp=(RotMat*dp')';
            
            % SCALE
            dp(:,2)=dp(:,2)./1;
            dp(:,1)=dp(:,1)./rescale(2);
            
        end
        
    end
    
    % 3D COORDINATE TRANSFORMATION
    if (nargin>2)&(n_dim==3);
        % NOT YET IMPLEMENTED, SEE GSLIB BOOK
        
        if length(transform)>1 % length(trasnform)=1 --> isotropic
        
            if length(transform)==3;
                % 2D Anisotropy only;
                t=transform;
                transform=zeros(1,6);
                transform([1,2,5])=t;
                transform(6)=1;
            end
            rescale=transform([1,5,6]);
            a=transform(2:4)*pi/180;
            
            % SGEMS DEF
            %T1 = [ 1 0 0 ; 0 cos(a(3)) sin(a(3)) ; 0 -sin(a(3)) cos(a(3))];
            %T2 = [ sin(a(2)) 0 -cos(a(2)) ; 0 1 0 ; cos(a(2)) 0 sin(a(2))];
            %T3 = [ sin(a(1)) -cos(a(1)) 0 ; cos(a(1)) sin(a(1)) 0 ; 0 0 1];
            
            % WIKIPEDIA
            T1 = [ 1 0 0 ; 0 cos(a(3)) -sin(a(3)) ; 0 sin(a(3)) cos(a(3))];
            T2 = [ cos(a(2)) 0 sin(a(2)) ; 0 1 0 ; -sin(a(2)) 0 cos(a(2))];
            T3 = [ cos(a(1)) -sin(a(1)) 0 ; sin(a(1)) cos(a(1)) 0 ; 0 0 1];
            
            RotMat=T1*T2*T3;
            
            % ROTATE
            dp=(RotMat*dp')';
            
            % SCALE
            dp(:,2)=dp(:,2)./1;
            dp(:,1)=dp(:,1)./rescale(2);
            dp(:,3)=dp(:,3)./rescale(3);
          
        end
        
    end
end

if n_dim==1
    D=abs(dp);
elseif n_dim==2
    D=sqrt(dp(:,1).^2+dp(:,2).^2);
else
    D=transpose(sqrt(sum(transpose(dp.^2))));
end
