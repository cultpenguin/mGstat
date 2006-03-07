function K=fresnel_punch(Vel,x,y,z,S,R,freq,alpha);

  if nargin<7, freq=7.7; end
  if nargin<8, alpha=1; end
  
  tS=punch(Vel(:),x,y,z,S);
  tR=punch(Vel(:),x,y,z,R);

  T=tS+tR;T=T-min(T(:));

  freq=7.7;
  alpha=1;
  K=munk_fresnel_2d(freq,T,alpha);
