% mspectrum : Amplitude and Power spectrum
% Call  :
%     function [A,P,kx]=mspectrum(x,dx)
% 
% 1D (A)mplitude and (P)owerspectrum of x-series with spacing dx
%

function [A,P,kx]=mspectrum(x,dx)

x=x-nanmean(x);
nx=length(x);
dkx=1./(nx*dx);
kx=dkx*[-nx/2:1:nx/2-1];

A=fftshift(abs(fft(x)));
P=fftshift(abs(fft(x).^2));
range=[floor(nx/2)+1:1:nx];
kx=kx(range);
A=A(range);
P=P(range);









