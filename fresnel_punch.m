% fresnel_punch : computes the sensitivity kernel for a wave traveling from S to R.
%
% CALL : 
%    [K,timeS,timeR]=fresnel_punch(Vel,x,y,z,S,R,freq,alpha);
%
% IN : 
%    Vel : Velocity field
%    x [1:nx] :
%    y [1:ny] :
%    z [1:nz] :
%    S [1,3] : Location of Source
%    R [1,3] : Location of Receiver
%    freq : frequency
%    alpha: controls exponential decay away ray path
%
% OUT :
%    K : Sensitivity kernel
%    R : Ray sensitivity kernel (High Frequency approx)
%    timeS : travel computed form Source
%    timeR : travel computed form Receiver
%
% TMH/2006
%
function [K,R,tS,tR]=fresnel_punch(Vel,x,y,z,S,R,freq,alpha);

  if nargin<7, freq=7.7; end
  if nargin<8, alpha=1; end
  
  tS=punch(Vel(:),x,y,z,S);
  tR=punch(Vel(:),x,y,z,R);

  T=tS+tR;T=T-min(T(:));

  K=munk_fresnel_2d(freq,T,alpha,1./tS,1./tR);

  % Normalize 
  %K=K./(sum(K(:)));
  
  if nargin>1
    % FIND RAYPATH ONLY WORKS FOR 2D CROSS BOREHOLE
    R=K.*0;
    for ix=1:length(x);
      m=min(T(ix,:));
      m=m(1);
      loc=find(T(ix,:)==m);
      R(ix,loc)=1;      
    end
    % Normalize 
    R=R./(sum(R(:)));
    
  end
  