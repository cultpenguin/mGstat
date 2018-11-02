% nanmean : mean of data, ignoring NaN's
% 
% call : meandata=nanmean(data)
%
% data [n-dimensional array]
% meandata [scalar]
%
% TMH(tmh@gfy.ku.dk), 2001
%
function [nmean]=nanmean(data)

if isempty(data),
    nmean=NaN;
    return
end


if size(data,2)>1
    if size(data,1)==1;
        nmean=nanmean(data(:));
        return
    else
        for i=1:size(data,2)
            nmean(i)=nanmean(data(:,i));
        end
    end
    return
end

npos=find( (isnan(data)==0) & (isinf(data)==0) );

if length(npos)==0,
  nmean=NaN;
else
  nmean=mean(data(npos)); 
end
  
