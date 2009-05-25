% grad_deform : Gradual deformation of X1 into X2
%
%
% X1 and X2 must have the same mean !!!
%
% Example : 
% 
%V=visim_init;
%V=visim(V);
%V.cond_sim=2;
%D=V.D;
%for i=1:100;
%    V.rseed=V.rseed+1;
%    V=visim(snesim_set_resim_data(V,D',[10 10]));
%    
%        V.cond_sim=0;
%        V=visim(V);
%    
%    doGradDef=1;
%    if doGradDef==1;
%        D=grad_deform(D-V.gmean,  V.D-V.gmean,.6)+V.gmean;
%    else
%        D=V.D;
%    end
%    
%    imagesc(D);
%    caxis([8 12]);
%    colorbar;
%    drawnow;
%end
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