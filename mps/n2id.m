function id = n2id(n, base)
% n2id: assigns ID number to a neighborhood
%
% CALL: 
%      id = n2id(n, base)
%      
% INPUT
%     n     vector, sN x 1, with the values of the voxels in the
%           neighborhood
%     base  vector, 1 x sN, base = (sV*ones(1,sN)).^(0:sN-1), see id2n for
%           definitions of sV and sN
%
%
% OUTPUT
%     id    scalar, integer ID number of the neighborhood, id > 0.
%
% 
% See also id2n
%
% 2014, Katrine Lange
%  
  id = base * n + 1;
