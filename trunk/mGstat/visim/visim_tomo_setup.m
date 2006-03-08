%visim_tomo_setup
%
% CALL : 
%   [fvolgeom,fvolsum,G]=visim_tomo_setup(V_ref,x,y,z,S,R,t,dt,name)
%
%   S  [nobs,ndim] : Source position
%   R  [nobs,ndim] : Receiver position
%   t  [nobs,1]    : travel observed between S and R
%   dt [nobs,1 ]   : travel time measurement error
%   name [string]  : name to be appended to EAS files
%   type [0]=raytracing [1]=kernel (default)

% TMH/2006
%
function [fvolgeom,fvolsum,G]=visim_tomo_setup(m_ref,x,y,z,S,R,t,dt,name,type)

if nargin<8,  dt=t.*0;  end
if nargin<9,  name='def';  end
if nargin<10,  type=1;  end
doPlot=0;

freq=8;
alpha=1;

G=zeros(size(S,1),length(m_ref(:)));

for i=1:size(S,1);
  if type==1
    % FRESNEL KERNEL
    [K,Ray,tS,tR]=fresnel_punch(m_ref,x,y,z,[S(i,:),0],[R(i,:),0],freq,alpha);  
  else
    % HIGH FREQ APPROX
    [Ray,K,tS,tR]=fresnel_punch(m_ref,x,y,z,[S(i,:),0],[R(i,:),0],freq,alpha);  
  end
  maxK=max(K(:));
  
  K(find(K< (.001.*maxK) ))=0;
  gg=K(:)';
  gg=gg./sum(gg(:));
  G(i,:)=gg;
  
  if doPlot==1
    imagesc(reshape(gg,length(x),length(y))')
    axis image;
    caxis([0 0.05])
    drawnow;;
  end
end

[xx,yy,zz]=meshgrid(x,y,z);

nd=length(find(G));
VolGeom=zeros(nd,5);
VolSum=zeros(size(S,1),4);



i=0;

for iv=1:size(S,1);
  g=G(iv,:);
  id=find(g);
  for ip=1:length(id);
    Garr=[xx(id(ip)) yy(id(ip)) zz(id(ip)) iv g(id(ip))];
    
    i=i+1;
    VolGeom(i,:)=Garr;    
  end

  % CALC VELOCITY FROM DT
  VolSum(iv,:)=[iv length(id) t(iv) dt(iv)]; 
  
end

fvolgeom=sprintf('visim_volgeom_%s.eas',name);
fvolsum=sprintf('visim_volsum_%s.eas',name);

write_eas(fvolgeom,VolGeom);

write_eas(fvolsum,VolSum);
