
% kernel_buursink_2k : Computes 2D Sensitivity kernel based on 1st order EM scattering theory
% 
% See 
%   Buursink et al. 2008. Crosshole radar velocity tomography 
%                         with finite-frequency Fresnel. Geophys J. Int.
%                         (172) 117;
%
%  CALL : 
%     % specify a source trace (dt, wf_trace):
%     [kernel,L,L1_all,L2_all]=kernel_buursink_2d(model,x,z,S,R,dt,wf_trace);
%     % Use a ricker wavelet with center frequency 'f0'
%     [kernel,L,L1_all,L2_all]=kernel_buursink_2d(model,x,z,S,R,f0));
%
%
% Knud Cordua, 2009, 
% Thomas Mejer Hansen (small edits, 2009)
%
                                    
function [kernel,L,L1_all,L2_all,tS,tR,omega,Y]=kernel_buursink_2d(model,x,z,S,R,omega,P_omega,useEik,doPlot);

% Fresnell volume
if nargin<1
    model=ones(100,100)*((0.14*10^9));
    model=ones(60,120)*((0.14*10^9));
end
[nz,nx]=size(model);

if nargin<9
    doPlot=0;
end

if nargin<6 % no omega
    f0=0.1*2;
    omega=f0;
end

if nargin<7 % no P_omega
    f0=omega;
    dt=0.02;
    Nt=1500;
    wl=rickerwavelet(f0,dt,Nt);
    [A,P,Psmooth,kx]=mspectrum(wl,dt);
    P_omega=A;
    omega=2*pi*kx;
    P_omega = P_omega ./ sum(P_omega.*(omega(2)-omega(1)));
end

if nargin<8
    useEik=1;
end

clipOmega=0;
if clipOmega==1
    % REMOVE LARGEST P_omega values
    iomega=find(cumsum(P_omega)<0.995*sum(P_omega));
    omega=omega(iomega);
    P_omega=P_omega(iomega);
end

if useEik==0
    model_mean=mean(model(:));
    model=model.*0+model_mean;
end

if nargin<2; x=[1:1:nx]*.05; end
if nargin<3; z=[1:1:nz]*.05; end
if nargin<4; S=[x(4) z(round(length(z)/2))];end
if nargin<5; R=[x(length(x)-4) z(round(length(z)/2))];end

try dx_x=x(2)-x(1);catch;dx_x=x(1);end
try dx_z=z(2)-z(1);catch;dx_z=z(1);end

if ~(dx_x==dx_z);
    mgstat_verbose(sprintf('%s : DX must equal DZ (%g,%g)',mfilename,dx_x,dx_z))
    %return
end

dx=dx_x;

kernel=zeros(nz,nx);

trn(1)=round(interp1(x,1:1:nx,S(1)));
trn(2)=round(interp1(z,1:1:nz,S(2)));
rec(1)=round(interp1(x,1:1:nx,R(1)));
rec(2)=round(interp1(z,1:1:nz,R(2)));


Y=P_omega.^2;


% COMPUTE KERNEL tS
if useEik==0
    L=dx*sqrt((trn(1)-rec(1))^2+(trn(2)-rec(2))^2);
    tS=[];
    tR=[];
else
    tS=fast_fd_2d(x,z,model,S);
    tR=fast_fd_2d(x,z,model,R);
    %tS=fast_fd_2d(x,z,model,S);
    %tR=fast_fd_2d(x,z,model,R);
    L = eikonal_raylength(x,z,model,S,R,tS);
end

if nargout>2
    L1_all=zeros(nz,nx);
    L2_all=zeros(nz,nx);
end
for i=1:nz
    % progress_txt([i],[nz],'Z',0)
        
    for j=1:nx
        
        P=[x(j) z(i)];
        
        if useEik==0
            L1=dx*sqrt((trn(1)-j)^2+(trn(2)-i)^2);
            L2=dx*sqrt((j-rec(1))^2+(i-rec(2))^2);           
        elseif useEik==1                       
            L1 = eikonal_raylength(x,z,model,S,P,tS);
            L2 = eikonal_raylength(x,z,model,R,P,tR);
        else
            L1 = tS(i,j).*mean(model(:));
            L2 = tR(i,j).*mean(model(:));
        end
        if nargout>2
            L1_all(i,j)=L1;L2_all(i,j)=L2;
        end
        
        % 2D
        A=trapz(omega,sqrt(omega.^3).*Y.*sin( (omega./model(i,j))*(L1+L2-L) +pi/4));
        B=trapz(omega,omega.*Y);
        kernel(i,j)=sqrt(1/(2*pi)) * sqrt(L/(L1*L2)) * model(i,j).^(-0.5) * (A/B);

        % 3D
        %A=trapz((omega.^(3)).*Y.*sin( (omega./model(i,j))*(L1+L2-L)), omega);
        %B=trapz(omega.^2.*Y, omega);
        %kernel(i,j)=(model(i,j)*2*pi).^(-1)*(L/(L1*L2)) * (A/B);
        
        if (sum(abs(P-S))==0)|(sum(abs(P-R))==0)                      
            kernel(i,j)=0;
        end
        
    end
    if doPlot>1
        figure_focus(2);imagesc(kernel);
        cax=caxis;cax=[-1 1].*max(abs(cax));caxis(cax);
        colormap(cmap_linear([1 0 0;1 1 1;0 0 0]))
        axis image
        drawnow;
    end
end


kernel=kernel.*dx*dx;

%% NEXT FEW LINE SHOULD BETTER HANDLE THE SENSITIVITY AT THE SOURCE AND
% RECEIVER LOCATIONS
pos=find(isnan(kernel)>0);
pos=find(isinf(kernel)>0);
for i=1:length(pos);
    [iz,ix]=ind2sub([nz,nx],pos(i));
    try
        % USE AVERAGE AROUND SINGULAR POINT
        kernel(iz,ix)=(kernel(iz,ix-1)+kernel(iz,ix+1))/2;
    catch
        kernel(iz,ix)=0;
    end
    
end


%% NORMALIZE SENSITIVITY KERNEL
%disp(sprintf('BUURSINK : sum(kernel)=%g, L=%g',sum(kernel(:)), L))
doNormalize=1;
if doNormalize==1
    kernel=L*kernel./sum(kernel(:));
end

if doPlot>0;
    figure_focus(1);
    
    iy=find(Y==max(Y));iy=iy(1);omega_peak=omega(iy);
    
    lambda_peak=model(1,1)./omega_peak;
    
    fresnel_width=sqrt(lambda_peak*L)/2;
    disp(sprintf('Fresnel_width=%gm peak freq = %g MHz',fresnel_width,(omega_peak/2*pi)));
    
    
    f_zones=[1:4].*lambda_peak/2;
    subplot(2,2,1);imagesc(x,z,model);axis image;colorbar
    subplot(2,2,2);imagesc(x,z,kernel);axis image;colorbar;cax=caxis;
    cax=[-1 1].*max(abs(cax));
    caxis(cax);
    colormap(cmap_linear([1 0 0;1 1 1;0 0 0]))
    if nargout>1
        delta_t=[L1_all + L2_all - L];
        hold on
        contour(x,z,delta_t,f_zones,'w-')
        hold off
        caxis(cax)
    end
    subplot(2,1,2);plot(omega/(2*pi),Y,'k-',[1 1].*omega_peak/(2*pi),[0 1].*max(Y),'r-');
    drawnow;
    
end