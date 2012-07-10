% despike : remove spikes from data series
%
% Example 
% 
%   limit=1000;
%   [dout] = despike(data,1000); % removes any data above a certain threshold
%
function [dout] = despike(data,limit);


if nargin==1;
     limit=max(abs(diff(data)))*.1;
     disp(sprintf('%s : settting limit=%g',mfilename,limit))
end

ibad=find(abs(diff(data))>limit);
dout=data;
dout(ibad+1)=NaN;

% interp
ii_nan=find(isnan(dout));
ii=find(~isnan(dout));
dout(ii_nan)=interp1(ii,dout(ii),ii_nan,'cubic','extrap');
