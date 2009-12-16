% 2D frechet kernel, First Fresnel Zone 
%
% See Jensen, Jacobsen, Christensen-Dalsgaard (2000) Solar Physics 192.
%
% Call :
% S=munk_fresnel_2d(T,dt,alpha,As,Ar,K);
%
% T : dominant period
% dt : 
% alpha : degree of cancellation 
% As : Amplitude fo the wavefield propagating from the source
% Ar : Amplitude fo the wavefield propagating from the receiver
% K : normalization factor
function S=munk_fresnel_2d(T,dt,alpha,As,Ar,K);

  if nargin<2,    
    eval(['help ',mfilename])
    return
  end
  
  if nargin<3,
    alpha=0.7;
  end

  if nargin<4;
    S=cos(2*pi*dt./T).*exp(-(alpha*dt./(T/4)).^2);
    return
  end
  
  if nargin<6,  
    K=1;
  end
  if nargin<5,
    Ar=ones(size(dt));
  end
  if nargin<4,
    As=ones(size(dt));
  end
  
  S=K*As.*Ar.*cos(2*pi*dt./T).*exp(-(alpha*dt./(T/4)).^2);