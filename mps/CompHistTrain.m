function [H, nV] = CompHistTrain(Z, N, sV)
%function [H, ids, nV] = CompHistTrain(Z, N, nc, mc, pc, sV)
%
%
% INPUTS
%  Z         binary valued training image (for now... )
%  N         binary neighborhood mask
%  nc,mc,pc  center coordinates of the mask
%  sV        the image must have the categories 0,1,...,sV
% IncCenter: 1 if included, 0 it not. If on, the cetner pixel is also
%            inclueded in the pattern.
%
% OUTPUTS
%  H ...


if nargin <2
    N=ones(3,3);
end
if nargin<3
    [yN xN zN]=size(N);
    yc = ceil(yN/2); %y
    xc = ceil(xN/2); %x
    zc = 1; %z
    sV=1;
end

nc=1;mc=1;pc=1;

% Size of the training image
[nZ, mZ, pZ] = size(Z);

% Size of the neighbourhood mask
[nN, mN, pN] = size(N);

% Modified by KSC:
% if N(nc, mc, pc) ~= 0
%    N(nc,mc,pc) = 0;
%    warning('The center coordinate of the mask has been set to 0')
% end

sN = sum(N(:));

% Base of the conversion from neighborhood to ID
base = ((sV)*ones(1,sN)).^(0:sN-1);

% Number of voxels that are center in a neighborhood
nV = (mZ-mN+1)*(nZ-nN+1)*(pZ-pN+1);

% Indexes of the voxels
index = reshape(1:nZ*mZ*pZ, [nZ, mZ, pZ]);

% Histogram
H = zeros(1,(sV)^sN);
%H = zeros(1,nZ*mZ);
%ids = zeros(1,nZ*mZ);

%c=0;
% For all inner voxels
for k = pc : pZ-(pN-pc)
   for j = mc : mZ-(mN-mc)
      for i = nc : nZ-(nN-nc)
         
         % The indexes of the rectangular neighborhood
         dim1 = i-nc+1 : i-nc+nN; 
         dim2 = j-mc+1 : j-mc+mN; 
         dim3 = k-pc+1 : k-pc+pN; 

         % Neighbors ID of the voxel
         ijk = index(dim1,dim2,dim3);
                  
         % Voxel values of Nk
         zijk = Z(ijk);
         nijk = zijk(N==1);
       
         % Identify neighborhood id:
         hijk = n2id(nijk(:), base);
         
         %if sum(ids==hijk)==1
         %    H(ids==hijk)=H(ids==hijk)+1;
         %else
         %    c=c+1;
         %    ids(c)=hijk;
         %    H(ids==hijk)=H(ids==hijk)+1;
         %end
         
         %Modified by ksc:
         %H(zijk(nc,mc,pc)+1,hijk) = H(zijk(nc,mc,pc)+1, hijk) + 1;
         H(1, hijk) = H(1, hijk) + 1;
         
         % H((hijk-1)*(sV+1) + zijk(nc,mc,pc)+1) = H((hijk-1)*(sV+1) + zijk(nc,mc,pc)+1) + 1;
      end
   end
 end