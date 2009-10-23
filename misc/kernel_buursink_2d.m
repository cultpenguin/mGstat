% kernel_buursink_2k : Computes 2D Sensitivity kernel based on 1st roder EM scattering theory
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
% Thomas Mejer Hansen (small editts, 2009)
%
                                    
function [kernel,L,L1_all,L2_all]=kernel_buursink_2d(model,x,z,S,R,dt,wf_trace,useEik);


% Fresnell volume
if nargin<1
    model=ones(100,100)*((0.14*10^9));
    model=ones(60,120)*((0.14*10^9));
    
end
[nz,nx]=size(model);


if nargin<7
    if nargin<6
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

if nargin<8
    useEik=0;
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

%dx=0.2; % m
dx=dx_x;

kernel=zeros(nz,nx);

trn(1)=round(interp1(x,1:1:nx,S(1)));
trn(2)=round(interp1(z,1:1:nz,S(2)));
rec(1)=round(interp1(x,1:1:nx,R(1)));
rec(2)=round(interp1(z,1:1:nz,R(2)));


%% COMPUTE POWERSPECTRUM OF TRACE
y=wf_trace;
L=length(y);
Fs=1/dt;
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y=fft(y,NFFT);
Y=abs(Y(1:NFFT/2)).^2;

delta_f=1/dt;
omega=pi*delta_f*linspace(0,1,NFFT/2);

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
else
    tS=fast_fd_2d(x,z,model./1e+9,S);
    tR=fast_fd_2d(x,z,model./1e+9,R);
    %tS=fast_fd_2d(x,z,model,S);
    %tR=fast_fd_2d(x,z,model,R);
    L = eikonal_raylength(x,z,model./1e+9,S,R,tS);
end
L1_all=zeros(nz,nx);
L2_all=zeros(nz,nx);

    

for i=1:nz
    progress_txt([i],[nz],'Z',0)
        
    for j=1:nx
        %progress_txt([i,j],[nz,nx],'Z','X',0)
        % F�lgende "if" s�tning er et fors�g p� at begr�nse omr�det hvori der beregnes v�rdier - for at speede hastigheden op
        % Dette er taget fra Spetzler and Snieder, 2004 side 2
        %if q(i,j)<sqrt((2*lamda*(dx*L_s-dx*(j-trn(1)))*dx*(j-trn(1)))/(n*dx*L_s)) && dx<sqrt((2*lamda*(dx*L_s-dx*(j-trn(1)))*dx*(j-trn(1)))/(n*dx*L_s));
        
        P=[x(j) z(i)];
        
        if useEik==0
            L1=dx*sqrt((trn(1)-j)^2+(trn(2)-i)^2);
            L2=dx*sqrt((j-rec(1))^2+(i-rec(2))^2);           
        else           
            L1 = eikonal_raylength(x,z,model./1e+9,S,P,tS);
            L2 = eikonal_raylength(x,z,model./1e+9,R,P,tR);
            %L1 = eikonal_raylength(x,z,model,S,P,tS);
            %L2 = eikonal_raylength(x,z,model,R,P,tR);
        end
        L1_all(i,j)=L1;L2_all(i,j)=L2;
        
        %A=trapz((omega.^2).*sqrt(omega).*Y.*sin( (omega./model(i,j))*(L1+L2-L) +pi/4) )*pi*delta_f; % KNUD
        %B=trapz((omega.^2).*Y)*pi*delta_f; % KNUD ORIG
        A=trapz((omega.^(1.5)).*Y.*sin((omega./model(i,j))*(L1+L2-L)+pi/4))*pi*delta_f;
        B=trapz((omega).*Y)*pi*delta_f;
        kernel(i,j)=sqrt(1/(2*pi)) * sqrt(L/(L1*L2)) * 1/(sqrt(model(i,j))*model(i,j)^2)*(A/B);
        
        if (sum(P-S)==0)|(sum(P-R)==0)
           kernel(i,j)=0;
        end
        
        %end
    end
end
%imagesc(kernel);axis image;drawnow
% NEXT FEW LINE SHOULD BETTER HANDLE THE SENSITIVITY AT THE SOURCE AND
% RECEIVER LOCATIONS
pos=find(isnan(kernel)>0);
pos=find(isinf(kernel)>0);
kernel(pos)=0;

kernel=L*kernel./sum(kernel(:));
