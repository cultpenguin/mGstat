% lowpass1 : 1D Low pass filtering
%
% F = [data,filter,kx,kz]=lowpass1(data,cutoff,dx,n,pdata);
% 
% data : 1D input data series 
% cutoff : cutoff frequency
% n : order of filter (Higher order = steeper filter)
% dx : spatial sampling rate
% pdata : [1] plot filter, [0] no plotting
%
% (C) TMH@GFY.KU.DK, 07/2001
%
% Reference :
% 
% http://www.cs.uwa.edu.au/undergraduate/courses/233.412/Labs/Lab5/lab5.html
% Department of Computer Science
% Computer Vision 233.412 
% The University of Western Australia
% The Butterworth filter is simply a convenient equation that allows you to specify a `bump', of height 1, centred on the origin. 
%
%                  1.0
%  F  =   ______________________   ,
%                           2*n
%         1.0 + (r / cutoff)
%
%
% where r is the distance from the origin, the radius of the bump 
% is specified by cutoff and the sharpness of its boundary is 
% controlled by the parameter n (a positive integer). 
% This `bump' centred on the origin acts as a low-pass filter - 
% letting through low frequencies in the image and blocking out the 
% high frequency components. The cut off radius specifies the cut 
% off frequency - the point at which frequencies start being `cut off'. 

function [data2,filterdata,kx,kz]=LowPass1(data,cutoff,dx,n,pdata);
  

if nargin==0,
    load clown;
    data=X(100,:);
    dx=0.004;
    cutoff=10;
    n=9;
    pdata=1;
end

if length(data)<1
  data2=[];
  disp([mfilename,' - No data points - skipping'])
  return;
end

if (size(data,1)==1);
  ndata=size(data,2);
  data=[data,fliplr(data)];  
else
  ndata=size(data,1);
  data=[data;flipud(data)];  
end





if nargin==3,
  n=9;
end

if exist('pdata')==0;
    pdata=0;
end

meandata=nanmean(data(:));
data=data-meandata;

dx;
nx=length(data);
x=[1:1:nx]*dx;

dkx=1./(nx*dx);

kx=dkx*[-nx/2:1:nx/2-1];
Fdata=fftshift(fft(data));

filterdata=1./( 1 + (kx./cutoff).^(2*n)  );

data2=real(ifft(ifftshift(Fdata.*filterdata)));


data=data+meandata;
data2=data2+meandata;
data2=data2(1:ndata);

if pdata==1,
  subplot(3,2,1)
  plot(kx,filterdata);
  xlabel('Frequency [Hz]')
  ylabel(['Filter'])
  ax=axis;
  axis([-2*cutoff 2*cutoff -.1 1.1])

  title('filter')
  subplot(3,2,3)
  semilogy(kx,(abs(Fdata)));title('Freq Spec')
  ax=axis;
  axis([-10*cutoff 10*cutoff ax(3) ax(4)])

  subplot(3,2,5)
  semilogy(kx,(abs(Fdata.*filterdata)));title('Freq domain filtering');
  ax=axis;
  axis([-10*cutoff 10*cutoff ax(3) ax(4)])

  subplot(1,2,2)
  plot(data(1:ndata),x(1:ndata),'k-',data2,x(1:ndata),'r-');legend('orig data','filtered');ax=axis;
  %subplot(3,2,6)
  %plot(data2);title('filtered data');
  %subplot(3,2,4)
  %plot(data);title('filtered data');
  
  suptitle(['Butterworth Filter, CutOff=',num2str(cutoff),' Hz, n=',num2str(n)]);
  
end
