% rickerwavelet
% 
% Call:
%    w=rickerwavelet(f0,dt,Nt)
%
% Knud Cordua, 2009, 
%
%
function w=rickerwavelet(f0,dt,Nt)

% Call: w=rickerwavelet(f0,dt,Nt);
% f0: is the central frequency
% dt: is the temporal sample interval
% Nt: is the number of smaples in the wavelet

%f0=100*10^6;
%time=0:dt:50*10^-9; % dt=4.2456*10^-11;
% if nargin<3,t0=15*10^-9;end
% if nargin<3,
% dt=0.1*10^-9;
% Tp=1/(f0*dt);
% tmp=f0*dt*(-Tp+time+1);
% end
%w=(1-2*pi^2*tmp.^2).*exp(-pi^2*tmp.^2);
%w=(1-2*pi^2*f0^2*(time-t0).^2).*exp(-pi^2*f0^2*(time-t0).^2);
%Nt=2/(100*10^6*0.1*10^-9);

time=1:Nt;
Tp=1/(f0*dt);
tmp=f0*dt*(-Tp+time+1);
w=(1-2*pi*pi*tmp.*tmp).*exp(-pi*pi*tmp.*tmp);
