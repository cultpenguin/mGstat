% rot2 : 2D coordiante transformation 
%
% Call : 
%   htrans=rot2(h,ang,ani,dir)
%
% h :[hx,hy] location
% ang : angle in radians
% ani : anisotropy factor 
% 
% dir : 'direction' =1, normal transform, <>1, inverse transform
%
%
% TMH/2005
%

function htrans=rot2(h,ang,ani,dir)

  if nargin==3, 
    dir=1;
  end
    
  
  if dir==1
    Rot=[cos(ang) -sin(ang);sin(ang) cos(ang)];    
    D=[1 0 ; 0 ani];
    hrot=Rot*h(:);
    htrans = D * hrot;
  else 
    Rot=[cos(-ang) -sin(-ang);sin(-ang) cos(-ang)];    
    D=[1 0 ; 0 1./ani];
    
    hscale = D * h;    
    htrans=Rot*hscale;
  end

