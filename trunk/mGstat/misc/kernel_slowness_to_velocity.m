% kernel_slowness_to_velocity
function G_vel=kernel_slowness_to_velocity(G,V);

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
    t=G*(1./varr)
    for i=1:nxy
        G_vel(:,i)=(G(:,i)/varr(i))./t;
    end
    return
end