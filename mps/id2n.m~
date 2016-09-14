function [n,base] = id2n(id, sV, sN)
% id2n: returns the neighborhood of a given ID number
%
% Call:
%    [n,base] = id2n(id, sV, sN)
%
% INPUT
%     id    scalar, integer ID number of the neighborhood, id > 0
%     sV    scalar, number of different values the voxels can take, sV = 2
%           for binary images
%     sN    scalar, number of neighbors of a voxel (not on the boundary)
%
%
% OUTPUT
%     n     vector, sN x 1, with the values of the voxels in the
%           neighborhood
%     base  vector, 1 x sN, base = ((sV)*ones(1,sN)).^(0:sN-1), see id2n for
%           definitions of sV and sN
%
% See also n2id
% 
%
% 2014, Katrine Lange
%  

%
n = zeros(sN,1);
id = id - 1;

for i = 1:sN
   idi = floor(id / (sV));
   n(i) = id - (sV)*idi;
   id = idi;
end

if nargin>1
    base = ((sV)*ones(1,sN)).^(0:sN-1);
end
