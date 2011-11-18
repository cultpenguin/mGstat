% mspectrum : Amplitude and Power spectrum
% Call  :
%     function [A,P,kx]=mspectrum(x,dx)
% 
% 1D (A)mplitude and (P)owerspectrum of x-series with spacing dx
%

function [A,P,smoothP,kx]=mspectrum(x,dx)

min_size=min(size(x));
if min_size>1
    % TREAT EACH COLUMN AS A DATA SERIES
    %if size(x,2)~=min(size(x)); x=x'; end    
    for i=1:min_size        
        [A(:,i),P(:,i),smoothP(:,i),kx]=mspectrum(x(:,i),dx);
        
        
    end
    return
end
    
    

%x=x-nanmean(x);
nx=length(x);
dkx=1./(nx*dx);
kx=dkx*[-nx/2:1:nx/2-1];

A=fftshift(abs(fft(x)));
P=fftshift(abs(fft(x).^2));
range=[floor(nx/2)+1:1:nx];
kx=kx(range);
A=A(range);
P=P(range);
smoothP=conv(P,ones(1,9)/9);









