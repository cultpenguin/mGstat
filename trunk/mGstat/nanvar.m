% nanvar : var of data, ignoring NaN's
% 
% call : vardata=nanvar(data)
%
% data [n-dimensional array]
% vardata [scalar]
%
% TMH(tmh@gfy.ku.dk), 2001
%
function [nvar]=nanvar(data)

if isempty(data),
    nvar=NaN;
    return
end

if size(data,2)>1
    for i=1:size(data,2)
        nvar(i)=nanvar(data(:,i));
    end
    return
end


npos=find( (isnan(data)==0) & (isinf(data)==0) );
if length(npos)==0,
  nvar=NaN;
else
  nvar=var(data(npos)); 
end
  
