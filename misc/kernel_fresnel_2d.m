%function [kernel_t,kernel_a,P_omega,omega]=kernel_fresnel_2d(v,x,y,S,R,f0,gamma);
function [kernel_t,kernel_a,P_omega,omega]=kernel_fresnel_2d(v,x,y,S,R,omega,P_omega);

doPlot=1;

omega_max=omega(find(P_omega==max(P_omega)));omega_max=omega_max(1);
f0=omega_max/(2*pi);

%% compute wavlet / spectrum
% eqn 6a, 6b Kiu et al, 2009.
%Nf=125;
%f=linspace(f0/30,2*f0,Nf);df=f(2)-f(1);
%omega=2*pi*f;d_omega=omega(2)-omega(1);
%P_omega = gamma_coefficients(2*pi*f0,gamma,omega);
d_omega=omega(2)-omega(1);
P_omega = P_omega ./ sum(P_omega.*d_omega);


%% COMPUTE L L1 L2
tS=fast_fd_2d(x,y,v,S);
tR=fast_fd_2d(x,y,v,R);
L = eikonal_raylength(x,y,v,S,R,tS);
%L1 = tS.*v;L2 = tR.*v;
L1 = tS.*mean(v(:));L2 = tR.*mean(v(:));

%% COMPUTE MONOKERNELS
n_omega=length(P_omega);
kernel_t=v.*0;
kernel_a=v.*0;
for i=1:n_omega
    progress_txt(i,n_omega)
    if nargout==1;
        [kernel_mono_t]=kernel_fresnel_monochrome_2d(v,x,y,S,R,omega(i),L,L1,L2);
        kernel_t=kernel_t + P_omega(i).*kernel_mono_t.*d_omega;
    else
        [kernel_mono_t,kernel_mono_a]=kernel_fresnel_monochrome_2d(v,x,y,S,R,omega(i),L,L1,L2);
        kernel_t=kernel_t + P_omega(i).*kernel_mono_t.*d_omega;
        kernel_a=kernel_a + P_omega(i).*kernel_mono_a.*d_omega;
    end     
    %imagesc(x,y,kernel_t);axis image;drawnow;
end

dt_max=(3/8)*mean(v(:))/(f0);
dt=L1+L2-L;

% ZERO BEYING 1st FRESNEL
kernel_t(find(dt>(2*dt_max)))=0;
try;kernel_a(find(dt>(2*dt_max)))=0;end

% zero outside first fresenl zone
%kernel_t(find(dt>(dt_max)))=0;
%kernel_a(find(dt>(dt_max)))=0;

kernel_a(find(isinf(kernel_a)))=0;
kernel_t(find(isinf(kernel_t)))=0;
kernel_a(find(isnan(kernel_a)))=0;
kernel_t(find(isnan(kernel_t)))=0;

% should next line be nescecary =
kernel_t=L*kernel_t./sum(kernel_t(:));
%kernel_a=L*kernel_a./sum(kernel_a(:));

if doPlot==1
    dt_max=2*pi*(3/8)*mean(v(:))/(2*pi*f0);
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
