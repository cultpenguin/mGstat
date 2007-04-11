% fast_fd_2d_traveltime_matrix Compute first arrival time for a series of S and R
%
% Call : 
% 
% [t,time]=fast_fd_2d_traveltime_matrix(x,y,v,S,R,uses);
%
% computes the travel time from all rays between sources S and receivers R.
%
% This is very fast when computing rays in for example a corss borehole 
% tomography setup
% 
% EXAMPLE
% nx=100;ny=120;
% x=[1:1:nx];
% y=[1:1:ny];
% v=ones(ny,nx);
% Sources=[2 10;2 80];
% nr=40;
% Receivers=[ones(nr,1)*nx-2,linspace(2,ny-1,nr)']
% t=fast_fd_2d_traveltime_matrix(x,y,v,Sources,Receivers)
% plot(t);
% xlabel('raynumber');ylabel('travel time')
%
% See also fast_fd_2d_traveltime_matrix and fast_fd_2d
%
function [t,time]=fast_fd_2d_traveltime_matrix(x,y,v,S,R,uses);

if nargin < 6 
    uses=1:size(S,1);
end

if length(uses)==0
    t=[];
    time=[];
    return
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
