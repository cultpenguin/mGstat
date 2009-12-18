% fast_fd_2d_traveltime Compute first arrival time for rays between series of S and R
%
% Computes the travel time (using nfd from Colin Zelts FAST package) from Source(s) to Receiver(s).
%
%
% Call : 
%   [t,time]=fast_fd_2d_traveltime(x,y,v,S,R,uses);
%
%
% Example :
%
% nx=100;ny=120;
% x=[1:1:nx];
% y=[1:1:ny];
% v=ones(ny,nx);
% Sources  =[2 10 ; 2 80];
% Receivers=[10 10;100 80];
% t=fast_fd_2d_traveltime(x,y,v,Sources,Receivers)
% plot(t);
% xlabel('raynumber');ylabel('travel time')
% 
%
%
function [t,time]=fast_fd_2d_traveltime(x,y,v,S,R,uses);

if nargin < 6 
    uses=1:size(S,1);
end

ns=size(S,1);
nr=size(R,1);

if (ns~=nr)
	disp(sprintf('%s : The size of S and R MUST be the same',mfilename))
	disp(sprintf('%s : If you want to calculate the traveltime between',mfilename));
	disp(sprintf('%s : all rays traveling between a list of S and R',mfilename));
	disp(sprintf('%s : please make use of fast_fd_3d_traveltime_matrix',mfilename));
	t=[];
	time=[];
	return
end	


S=S(uses,:);
R=R(uses,:);

autochunk=0;
% AUTo CHUNKING HAPPENS AUTOMATICALLY.... REMOVE
if autochunk==1
    SR_index=S(:,1)*(2*max(S(:,1)))+S(:,2);
    unique_SR=unique(SR_index);
    N_unique=length(unique_SR);
    if ~(N_unique==size(S,1))
        for i=1:N_unique;
            iuse=find(SR_index==unique_SR(i));
            [t(iuse),time]=fast_fd_2d_traveltime_matrix(x,y,v,S(iuse(1),:),R(iuse,:));
        end
        return
    end
end

[xx,yy]=meshgrid(x,y);

t0=fast_fd_2d(x,y,v,S);
for ishot=1:ns
    time{ishot}=interp2(xx,yy,t0(:,:,ishot),R(ishot,1),R(ishot,2));
    t( ishot)=time{ishot};
end
