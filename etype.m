function [E,Evar]=etype(D)
  [ny,nx,nsim]=size(D);
  E=zeros(ny,nx);
  for i=1:nsim
    E=E+D(:,:,i);
  end
  E=E./nsim;
  
  
  if nargout==2,
    Evar=zeros(ny,nx);
    for iy=1:ny
      for ix=1:nx
        Evar(iy,ix)=var(squeeze(D(iy,ix,:)));
      end
    end
  end