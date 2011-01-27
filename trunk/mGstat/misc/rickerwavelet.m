% rickerwavelet
% 
% Call:
%    [w,t]=rickerwavelet(f0,dt,Nt,t0)
%
% f0: is the central frequency
% dt: is the temporal sample interval
% Nt: is the number of smaples in the wavelet
% t0: The time center of the ricker wavelet
% 
% Example : 
%   f0=100*10^6;
%   dt=4.2456*10^-11;
%   time=0:dt:50*10^-9; % 
%   [w,t]=rickerwavelet(f0,dt);
%   plot(t,w);xlabel('time(s)');ylabel('wavelet amplitude')
%

% 27-01-2010 : TMH : time output, auto calc of Nt and t0 if not set 

function [w,time,t0,it0]=rickerwavelet(f0,dt,Nt,t0)

if nargin<3;
    Nt=(3/f0)./dt;
end

if nargin<4
    it0=ceil(Nt/2);
    t0=it0*dt;
else
    it0=floor(t0/dt);
end

%time=dt:dt:Nt*dt;
%w=(1-2*pi^2*f0^2*(time-t0).^2).*exp(-pi^2*f0^2*(time-t0).^2);
time=(dt:dt:Nt*dt)-t0;
w=(1-2*pi^2*f0^2*(time).^2).*exp(-pi^2*f0^2*(time).^2);
