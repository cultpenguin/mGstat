% grad_deform : Gradual deformation of X1 into X2
%
%
% X1 and X2 must have the same mean !!!
%
% Example : 
% 
% V=read_visim('visim_sph.par');
% m=.13;mm(1)=m;;
% Xnew=V.D(:,:,10);
% for i=2:V.nsim;
%  Xnew=grad_deform(Xnew-m,V.D(:,:,i)-m,pi/8)+m;
%  mm(i)=(mean(Xnew(:)));
%  mv(i)=(var(Xnew(:)));
% end
%
%
% See Hu and Ravalec-Dupin, 2004, Math Geol.
%
function X = grad_deform(X1,X2,t,doPlot)
  
  if nargin<3
    t=pi/2;
  end
  
  if nargin<4
    doPlot=0;
  end
  
  X = X1.*cos(t).^2 + X2.*sin(t).^2;
  
  
  if doPlot==1
    subplot(1,3,1)
    imagesc(X1);axis image;
    cax=[-1 1].*.03;caxis(cax)
    cax=caxis;
    subplot(1,3,2)
    imagesc(X2);axis image;caxis(cax)
    subplot(1,3,3)
    imagesc(X);axis image;;caxis(cax)
    drawnow
  end