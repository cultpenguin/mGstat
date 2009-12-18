% kernel_liu_2d : Computes 2D Sensitivity kernel based on 1st order EM scattering theory
% 
% See 
%   Liu er al., Sensitivity kernsels for seismic Fresnel volume tomoraphy.
%                         Geoophysics 75(5), 2009.
%                         (172) 117;
%
%  CALL : 
%     % specify a source trace (dt, wf_trace):
%     [kernel,L,L1_all,L2_all]=kernel_liu_2d(model,x,z,S,R,dt,wf_trace);
%     % Use a ricker wavelet with center frequency 'f0'
%     [kernel,L,L1_all,L2_all]=kernel_liu_2d(model,x,z,S,R,f0));
%
%
% Knud Cordua, 2009, 
% Thomas Mejer Hansen (small editts, 2009)
%
                                    
function [kernel,L,L1_all,L2_all,tS,tR,omega,Y]=kernel_liu_2d(model,x,z,S,R,dt,wf_trace,useEik,doPlot);

if nargin==0;
    dx=.05;
    x=[1:1:120]*dx;
    z=[1:1:60]*dx;
    v0=0.14;
    model=ones(length(z),length(x)).*v0;
    S=[.5 1.5];
    R=[5.5 1.5];
    
    f0=.1;
    dt=1/(16*f0);
    Nt=10*(1/f0)/dt;
    wf_trace=rickerwavelet(f0,dt,Nt);;plot(wf_trace)
    useEik=2;
    doPlot=1;
    [kernel,L,L1_all,L2_all,tS,tR,omega,Y]=kernel_liu_2d(model,x,z,S,R,dt,wf_trace,useEik,doPlot);
    return
end

% Fresnell volume
if nargin<1
    model=ones(100,100)*((0.14*10^9));
    model=ones(60,120)*((0.14*10^9));
end
[nz,nx]=size(model);

if nargin<9
    doPlot=0;
end

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

dx=dx_x;

if size(S,1)>1
    kernel=zeros(size(S,1),nx*nz);
    for i=1:size(S,1);
        progress_txt(i,size(S,1),'kernel')
        [k,L,L1_all,L2_all,tS,tR,omega,Y]=kernel_liu_2d(model,x,z,S(i,:),R(i,:),dt,wf_trace,useEik,doPlot);
        k=k';
        kernel(i,:)=k(:);
    end 
    return
end

kernel=zeros(nz,nx);

trn(1)=round(interp1(x,1:1:nx,S(1)));
trn(2)=round(interp1(z,1:1:nz,S(2)));
rec(1)=round(interp1(x,1:1:nx,R(1)));
rec(2)=round(interp1(z,1:1:nz,R(2)));


%% COMPUTE POWERSPECTRUM OF TRACE
y=wf_trace;
[A,P,k]=mspectrum(y,dt);
omega=2*pi*k;
A=A./(sum(A(:)));
P=P./(sum(P(:)));
Y=P;
delta_f=omega(2)-omega(1);


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
    tS=fast_fd_2d(x,z,model,S);
    tR=fast_fd_2d(x,z,model,R);

if nargout>2
    L1_all=zeros(nz,nx);
    L2_all=zeros(nz,nx);
end
for i=1:nz
    %progress_txt([i],[nz],'Z',0)
        
    for j=1:nx
        
        P=[x(j) z(i)];
        
        if useEik==0
            L1=dx*sqrt((trn(1)-j)^2+(trn(2)-i)^2);
            L2=dx*sqrt((j-rec(1))^2+(i-rec(2))^2);           
        elseif useEik==1           
            L1 = eikonal_raylength(x,z,model,S,P,tS);
            L2 = eikonal_raylength(x,z,model,R,P,tR);
            %L1 = eikonal_raylength(x,z,model,S,P,tS);
            %L2 = eikonal_raylength(x,z,model,R,P,tR);
        else
            %L1 = tS(i,j).*model(i,j);
            %L2 = tR(i,j).*model(i,j);
            L1 = tS(i,j).*mean(model(:));
            L2 = tR(i,j).*mean(model(:));
        end
        if nargout>2
            L1_all(i,j)=L1;L2_all(i,j)=L2;
        end
        
        % 2D
        A=trapz(Y.*sin( (sqrt(omega)./model(i,j))*(L1+L2-L) +pi/4), omega);
        kernel(i,j)=sqrt(1/(2*pi)) * sqrt(L/(L1*L2)) * model(i,j).^(-0.5) * (A);
        
        % 3D
        %A=trapz((omega.^(3)).*Y.*sin( (omega./model(i,j))*(L1+L2-L)), omega);
        %B=trapz(omega.^2.*Y, omega);
        %kernel(i,j)=(model(i,j)*2*pi).^(-1)*(L/(L1*L2)) * (A/B);
        
        
        
     
        if (sum(P-S)==0)|(sum(P-R)==0)
           kernel(i,j)=0;
        end
    end
end

% NEXT FEW LINE SHOULD BETTER HANDLE THE SENSITIVITY AT THE SOURCE AND
% RECEIVER LOCATIONS
pos=find(isnan(kernel)>0);
pos=find(isinf(kernel)>0);
kernel(pos)=0;

kernel=L*kernel./sum(kernel(:));




%doPlot=1;
if doPlot==1;
    figure;
    
    iy=find(Y==max(Y));iy=iy(1);omega_peak=omega(iy)
    
    lambda_peak=model(1,1)./omega_peak
    fresnel_width=sqrt(lambda_peak*L);
    disp(sprintf('Fresnel_width=%gm peak freq = %g Hz',fresnel_width,omega_peak));
    
    
    T=1./omega_peak;
    dt_max=3*T/8; % 2D time
    dist_max=mean(model(:))*dt_max;
    f_zones=[1:4].*dt_max;
    f_zones=[1:4].*dist_max;
    
    subplot(2,2,1);imagesc(x,z,model);axis image;colorbar
    subplot(2,2,2);imagesc(x,z,kernel);axis image;colorbar;cax=caxis;
   
    if nargout>2
        delta_t=[L1_all + L2_all - L];
        hold on
        contour(x,z,delta_t,f_zones,'w-')
        hold off
        caxis(cax)
        caxis([-1 1].*.0001)
        subplot(2,2,4);spy(delta_t<(mean(model(:))*dt_max))
  end
    subplot(2,2,3);plot(omega,Y,'k-',[1 1].*omega_peak,[0 1].*max(Y),'r-');
    
end
