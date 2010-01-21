% kernel_fresnel_monochrome_2d : 2D monchrome kernel for amplitude and first arrival
%
% Call:
%   [kernel_t,kernel_a]=kernel_fresnel_monochrome_2d(v,x,y,S,R,omega);
% or
%   [kernel_t,kernel_a]=kernel_fresnel_monochrome_2d(v,x,y,S,R,omega,L,L1,L2);
%
% Based on Liu, Dong, Wang, Zhu and Ma, 2009, Sensitivity kernels for
% seismic Fresenl volume Tomography, Geophysics, 75(5), U35-U46
%
% See also, kernel_fresnel_2d
%
function [kernel_t,kernel_a]=kernel_fresnel_monochrome_2d(v,x,y,S,R,omega,L,L1,L2);
doPlot=0;

if nargin<7
    tS=fast_fd_2d(x,y,v,S);
    tR=fast_fd_2d(x,y,v,R);
    L = eikonal_raylength(x,y,v,S,R,tS);
    %L1 = tS.*mean.*v;L2 = tR.*v;
    L1 = tS.*mean(v(:));L2 = tR.*mean(v(:));
end    
    
delta_t=(L1+L2-L)./v;

% 2D monchrome first arrival kernel, Liu et al, 2009, table 1, 2D K_T
A = sin(omega*delta_t +pi/4);
B = sqrt(omega)*sqrt(1/(2*pi)).*sqrt(L./(L1.*L2)).*sqrt(1./v);
kernel_t=A.*B;

if nargout>1
    % 2D monochrome amplitude kernel, Liu et al, 2009, table 1, 2D K_A
    A = cos(omega*delta_t +pi/4);
    B = sqrt(omega.^3)*sqrt(1/(2*pi)).*sqrt(L./(L1.*L2)).*sqrt(1./v);
    kernel_a=A.*B;
end    

if doPlot==1
    dt_max=2*pi*(3/8)*mean(v(:))/omega;
    clf,set_paper('portrait');
    subplot(1,min([nargout,2]),1)
    imagesc(x,y,kernel_t);axis image;
    cax=caxis;
    hold on
    contour(x,y,L1+L2-L,[1:1:3].*dt_max,'w-');
    hold off
    title('2D Arrival time kernel')
    caxis(cax)
    if nargout>1
        subplot(1,2,2)
        imagesc(x,y,kernel_a);axis image;
        cax=caxis;
        hold on
        contour(x,y,L1+L2-L,[1:1:3].*dt_max,'w-');
        hold off
        caxis(cax)
        title('2D Amplitude kernel')
    end
    suptitle(sprintf('omega=%g, f=%f',omega,omega/(2*pi)))
    drawnow;
end