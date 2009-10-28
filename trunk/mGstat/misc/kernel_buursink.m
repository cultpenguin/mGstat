% kernel_buursink_2k : Computes 2D/3D Sensitivity kernel based on 1st order EM scattering theory
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
% Currently only works in 2D!!!
%
% Knud Cordua, 2009, 
% Thomas Mejer Hansen (small edits, 2009)
%
                                    
function [kernel,L,L1_all,L2_all,tS,tR,omega,Y]=kernel_buursink(model,x,y,z,S,R,dt,wf_trace,dim,useEik,doPlot);

% Fresnell volume
if nargin<1
    model=ones(100,100)*((0.14*10^9));
    model=ones(60,120)*((0.14*10^9));
end
[nz,nx]=size(model);

if nargin<12
    doPlot=1;
end

if nargin<8
    if nargin<7
        f0=100*10^6;
        dt=4.245577806149431e-11;
        Nt=3000;
        wf_trace=rickerwavelet(f0,dt,Nt);
    else
        f0=dt;
        dt=4.245577806149431e-11;
        Nt=3000;
        wf_trace=rickerwavelet(f0,dt,Nt);
    end
end

if nargin<10
    useEik=0;
end

if nargin<9
    dim=2;
end

if useEik==0
    model_mean=mean(model(:));
    model=model.*0+model_mean;
end

if nargin<2; nx=10;x=[1:1:nx]*.05; end
if nargin<3; ny=10;y=[1:1:ny]*.05; end
if nargin<4; nz=10;z=[1:1:nz]*.05; end
if nargin<5; S=[x(4) z(round(length(z)/2))];end
if nargin<6; R=[x(length(x)-4) z(round(length(z)/2))];end

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


%% COMPUTE POWERSPECTRUM OF TRACE
y=wf_trace;
[A,P,omega_alt]=mspectrum(y,dt);
Y=P;
omega=omega_alt;
delta_f=omega(2)-omega(1);

%Calculate radius matrix
% See Spetzler and Snieder, 2004: 
SpetzlerSnieder2004_region=0;
if SpetzlerSnieder2004_region==1
    lamda=5;
    n=8/3;
    q=zeros(nz,nx);
    for i=1:nz
        progress_txt(i,nz,'z')
        for j=1:nx
            u=dx*[rec(1)-trn(1) trn(2)-rec(2)];
            a=dx*[j-trn(1) trn(2)-i];
            proj=norm(dot(a,u))/norm(u);
            q(i,j)=sqrt(abs(dx^2*((i-trn(2))^2+(j-trn(1))^2)-proj^2));
        end
    end
    L_s=sqrt((trn(2)-rec(2))^2+(trn(1)-rec(1))^2);
end

% COMPUTE KERNEL tS

if useEik==0
    L=dx*sqrt((trn(1)-rec(1))^2+(trn(2)-rec(2))^2);
    tS=[];
    tR=[];
else
    tS=fast_fd_2d(x,z,model./1e+9,S);
    tR=fast_fd_2d(x,z,model./1e+9,R);
    %tS=fast_fd_2d(x,z,model,S);
    %tR=fast_fd_2d(x,z,model,R);
    L = eikonal_raylength(x,z,model./1e+9,S,R,tS);
end

if nargout>2
    L1_all=zeros(nz,nx);
    L2_all=zeros(nz,nx);
end
for i=1:nz
    %progress_txt([i],[nz],'Z',0)
        
    for j=1:nx
        %progress_txt([i,j],[nz,nx],'Z','X',0)
        % F�lgende "if" s�tning er et fors�g p� at begr�nse omr�det hvori der beregnes v�rdier - for at speede hastigheden op
        % Dette er taget fra Spetzler and Snieder, 2004 side 2
        %if q(i,j)<sqrt((2*lamda*(dx*L_s-dx*(j-trn(1)))*dx*(j-trn(1)))/(n*dx*L_s)) && dx<sqrt((2*lamda*(dx*L_s-dx*(j-trn(1)))*dx*(j-trn(1)))/(n*dx*L_s));
        
        P=[x(j) z(i)];
        
        if useEik==0
            L1=dx*sqrt((trn(1)-j)^2+(trn(2)-i)^2);
            L2=dx*sqrt((j-rec(1))^2+(i-rec(2))^2);           
        elseif useEik==1           
            L1 = eikonal_raylength(x,z,model./1e+9,S,P,tS);
            L2 = eikonal_raylength(x,z,model./1e+9,R,P,tR);
            %L1 = eikonal_raylength(x,z,model,S,P,tS);
            %L2 = eikonal_raylength(x,z,model,R,P,tR);
        else
            %L1 = 1e-9*tS(i,j).*model(i,j);
            %L2 = 1e-9*tR(i,j).*model(i,j);
            L1 = 1e-9*tS(i,j).*mean(model(:));
            L2 = 1e-9*tR(i,j).*mean(model(:));
        end
        if nargout>2
            L1_all(i,j)=L1;L2_all(i,j)=L2;
        end
        
        if dim==2
            % 2D
            A=trapz((omega.^(1.5)).*Y.*sin( (omega./model(i,j))*(L1+L2-L) +pi/4), omega);
            B=trapz(omega.*Y, omega);
            kernel(i,j)=sqrt(1/(2*pi)) * sqrt(L/(L1*L2)) * model(i,j).^(-0.5) * (A/B);
        else
            % 3D
            A=trapz((omega.^(3)).*Y.*sin( (omega./model(i,j))*(L1+L2-L)), omega);
            B=trapz(omega.^2.*Y, omega);
            kernel(i,j)=(model(i,j)*2*pi).^(-1)*(L/(L1*L2)) * (A/B);
        end
        
        
        
        if (sum(P-S)==0)|(sum(P-R)==0)
           kernel(i,j)=0;
        end
        %end
    end
end

% NEXT FEW LINE SHOULD BETTER HANDLE THE SENSITIVITY AT THE SOURCE AND
% RECEIVER LOCATIONS
pos=find(isnan(kernel)>0);
pos=find(isinf(kernel)>0);
kernel(pos)=0;

kernel=L*kernel./sum(kernel(:));


if doPlot==1;
    figure;
    
    iy=find(Y==max(Y));iy=iy(1);omega_peak=omega(iy);
    
    lambda_peak=model(1,1)./omega_peak;
    
    fresnel_width=sqrt(lambda_peak*L)/2;
    disp(sprintf('Fresnel_width=%gm peak freq = %g MHz',fresnel_width,omega_peak./1e+6));
    
    
    f_zones=[1:4].*lambda_peak/2;
    subplot(2,2,1);imagesc(x,z,model);axis image;colorbar
    subplot(2,2,2);imagesc(x,z,kernel);axis image;colorbar;cax=caxis;
   
    if nargout>1
        delta_t=[L1_all + L2_all - L];
        hold on
        contour(x,z,delta_t,f_zones,'w-')
        hold off
        caxis(cax)
    end
    subplot(2,2,3);plot(omega,Y,'k-',[1 1].*omega_peak,[0 1].*max(Y),'r-');
    
end