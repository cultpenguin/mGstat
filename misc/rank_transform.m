% rank_transform : rank transform data
%
% Call : 
%   [r]=rank_transform(d);
%
function [r]=rank_transform(d)
  
  id=[1:1:length(d)]';
  sr=sortrows([id,d(:)],2);
  sr2=sortrows([id,sr],2);
  r=sr2(:,1);
