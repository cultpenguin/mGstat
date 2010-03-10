% kernel_fresnel_2d : sensitivity kernel for amplitude and first arrival
%
% Call:
%   [kernel_t,kernel_a,P_omega,omega]=kernel_fresnel_2d(v,x,y,S,R,omega,P_omega);
%
%
% Based on Liu, Dong, Wang, Zhu and Ma, 2009, Sensitivity kernels for
% seismic Fresenl volume Tomography, Geophysics, 75(5), U35-U46
%
% See also kernel_fresnel_monochrome_2d
%
% Run with no argument for an example.
%
%

function [kernel_t,kernel_a,P_omega,omega]=kernel_fresnel_2d(v,x,y,S,R,omega,P_omega,thres,doNormalize,doZeroOutsideFresnel,doPlot);

if nargin==0;
    dx=.0125;dy=dx;    
    x=[0:dx:7];
    y=[0:dy:6];
    S=[1 3];
    R=[6 3];
    v=0.14*ones(length(y),length(x));
    
    f0=.2;
    dt=4.245577806149431e-2;
    Nt=1500;
    wl=rickerwavelet(f0,dt,Nt);
    [A,P,kx]=mspectrum(wl,dt);
    P_omega=A;
    omega=2*pi*kx;
    P_omega = P_omega ./ sum(P_omega.*(omega(2)-omega(1)));
    
    figure(1);
    thres=0.999; % Numberof 
    doNormalize=0;
    doZeroOutsideFresnel=0;
    doPlot=0;
    
    [kernel_t,kernel_a,P_omega,omega]=kernel_fresnel_2d(v,x,y,S,R,omega,P_omega,thres,doNormalize,doZeroOutsideFresnel,doPlot);
    subplot(2,1,1);plot(omega,P_omega,'-*');
    subplot(2,2,3);imagesc(x,y,kernel_t);title('K_t')
    subplot(2,2,4);imagesc(x,y,kernel_a);title('K_a')
    return
end

if ~exist('doPlot','var');doPlot=0;end
if ~exist('doNormalize','var');doNormalize=0;end
if ~exist('doZeroOutsideFresnel','var');doZeroOutsideFresnel=0;end

if exist('thres','var');
    cs=cumsum(P_omega);
    ics=find(cs<(thres.*max(cs)));
    try
        ics=max(ics);
        omega=omega(1:ics);
        P_omega=P_omega(1:ics);
    end
end



dx=x(2)-x(1);
dy=y(2)-y(1);
dxy=dx*dy;


omega_max=omega(find(P_omega==max(P_omega)));omega_max=omega_max(1);
f0=omega_max/(2*pi);

d_omega=omega(2)-omega(1);
% Ensure int_w1^2 P(omega) * domega = 1, Liu, eqns. 5. 
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
    %if ((i/20)==round(i/20));progress_txt(i,n_omega);end
    if nargout==1;
        [kernel_mono_t]=kernel_fresnel_monochrome_2d(v,x,y,S,R,omega(i),L,L1,L2);
        kernel_t=kernel_t + P_omega(i).*kernel_mono_t.*d_omega;
    else
        [kernel_mono_t,kernel_mono_a]=kernel_fresnel_monochrome_2d(v,x,y,S,R,omega(i),L,L1,L2);
        kernel_t=kernel_t + P_omega(i).*kernel_mono_t.*d_omega;
        kernel_a=kernel_a + P_omega(i).*kernel_mono_a.*d_omega;
    end     
    if doPlot>1;
        subplot(2,2,1);imagesc(x,y,kernel_mono_t);axis image;drawnow;
        subplot(2,2,2);imagesc(x,y,kernel_mono_a);axis image;drawnow;
        subplot(2,2,3);imagesc(x,y,kernel_t);axis image;drawnow;
        subplot(2,2,4);imagesc(x,y,kernel_a);axis image;drawnow;
        drawnow;
    end
end

kernel_t=kernel_t*dxy;
kernel_a=kernel_a*dxy;


%% INTERPOLATE NAN VALUES
inan_t=find(isnan(kernel_t));
[iy,ix]=ind2sub([length(y) length(x)],inan_t);
for i=1:length(ix);
    data_y=kernel_t(:,ix(i));
    ii=setxor(1:length(y),iy(i));
    kernel_t(iy(i),ix(i))=interp1(ii,data_y(ii),iy(i));
end

%% ZERO INF and NAN values
kernel_a(find(isinf(kernel_a)))=0;
kernel_t(find(isinf(kernel_t)))=0;
%kernel_a(find(isnan(kernel_a)))=0;
%kernel_t(find(isnan(kernel_t)))=0;


%% optionally zero all energy outside 1st fresnel zone:
if (doZeroOutsideFresnel==1)
    dt_max=(3/8)*mean(v(:))/(f0);
    dt=L1+L2-L;
    kernel_t(find(dt>(dt_max)))=0;
    kernel_a(find(dt>(dt_max)))=0;
end

% NORMALIZE KERNEL :
% NEXT LINE SHOULD NOT BE BESSESCARY
if doNormalize==1
    kernel_t=L*kernel_t./sum(kernel_t(:));
end

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
