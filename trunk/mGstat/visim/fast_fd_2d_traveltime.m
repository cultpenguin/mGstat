% fast_fd_2d_traveltime Compute first arrival time for rays between series of S and R
%
% Call : 
% 
% [t,time]=fast_fd_2d_traveltime(x,y,v,S,R,uses);
%
function [t,time]=fast_fd_2d_traveltime(x,y,v,S,R,uses);

if nargin < 6 
    uses=1:size(S,1);
end

S=S(uses,:);

ns=size(S,1);
nr=size(R,1);
[xx,yy]=meshgrid(x,y);

t=ones(ns*nr,1);

t0=fast_fd_2d(x,y,v,S);

for ishot=1:ns
    time{ishot}=interp2(xx,yy,t0(:,:,ishot),R(:,1),R(:,2));
    i0=(ishot-1)*nr;
    t( i0+1:i0+nr)=time{ishot};
end
