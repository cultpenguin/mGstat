function [kernel]=kernel_fresnel_monochrome_2d(v,x,y,S,R,omega,L,L1,L2);

delta_t=(L1+L2-L)./v;
A = sin(omega*delta_t +pi/4);
B = sqrt(omega)*sqrt(1/(2*pi)).*sqrt(L./(L1.*L2)).*sqrt(1./v);
kernel=A;%.*B;

doPlot=1;
if doPlot==1
    dt_max=(3/8)*0.14/omega;
    clf,
    imagesc(x,y,kernel);axis image;
    cax=caxis;
    hold on
    contour(x,y,L1+L2-L,[1:1:3].*dt_max,'w-');
    hold off
    caxis(cax)
    drawnow;
    
end