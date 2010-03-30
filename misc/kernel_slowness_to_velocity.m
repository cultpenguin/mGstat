% kernel_slowness_to_velocity : converts from slowness to velocity parameterizations
%
% CALL:
%   G_vel=kernel_slowness_to_velocity(G,V);
% or 
%   [G_vel,v_obs]=kernel_slowness_to_velocity(G,V,t);
% or
%   [G_vel,v_obs,Cd_v]=kernel_slowness_to_velocity(G,V,t,Cd);
%
% 
function [G_vel,v_obs,Cd_v]=kernel_slowness_to_velocity(G,V,t,Cd_org);

nxy=prod(size(V));
varr=V(:);

if (sum(size(G)==size(V))==2)
   % SAME SIZE FOR G AND V
   
   dt=G./V;
   t=sum(sum(dt));
  
   G_vel=(dt)./t;
   return
end

if size(G,2)==nxy    
    
    l=sum(G');
    
    % NORMALIZE KERNEL FOR VELOCITY
    t_app=G*(1./varr);
    for i=1:nxy
        G_vel(:,i)=(G(:,i)/varr(i))./t_app;
    end
    
    if nargin>2
        % COMPUTE APPARENT VELOCITIES FROM TRAVEL TIME
        v_obs=l./t;
    end
    
    if nargin>3
        % COMPUTE Cd_velocity from Cd_traveltime
        v_obs_noise=l./(t+sqrt(diag(Cd_org)'));
        Cd_v=diag(v_obs-v_obs_noise).^2;
    end
    
end