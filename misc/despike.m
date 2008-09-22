% despike : remove spikes from data series
%
% Example 
% 
%   limit=1000;
%   do_interp=1; % interp NaN values
%   [dout] = despike(data,1000,1); % removes any 
%
function [dout] = despike(data,limit,do_interp);


if nargin==1;
%     (sort(diff(slow)))    
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

%if isnan(dout(length(dout)))
%    dout(length(dout))=dout(length(dout)-1);
%end