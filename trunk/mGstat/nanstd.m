% nanstd : std of data, ignoring NaN's
% 
% call : stddata=nanstd(data)
%
% data [n-dimensional array]
% stddata [scalar]
%
% TMH(tmh@gfy.ku.dk), 2001
%
function [nstd]=nanstd(data)
nstd=std(data(find(isnan(data)==0))); 

  
