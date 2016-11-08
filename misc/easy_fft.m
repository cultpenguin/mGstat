
function easy_fft(data,Fs)
% Call: easy_fft(data,Fs);
% * data: is input vector with data signal
% * Fs: is the the sampling frequency 1/T

y=data;
L = length(data);

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2);

% Plot single-sided amplitude spectrum.
plot(f*10^-6,2*abs(Y(1:NFFT/2))) 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (MHz)')
ylabel('|Y(f)|')