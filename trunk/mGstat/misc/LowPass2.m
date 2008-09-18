% lowpass2
%
% F = [data,filter,kx,kz]=lowpass2(data,cutoff,dx,a,pdata);
% 
% data : 1D input data series 
% cutoff : cutoff frequency, ex cutoff=[10 1]; 
% n : order of filter (Higher order = steeper filter)
% dx : spatial sampling rate, ex dx=[1 1]
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
function [data2,filterdata,kx,kz]=LowPass2(data,cutoff,dx,n,pdata);
if nargin==0,
    load clown;
    data=X;
    dx=0.004;
    cutoff=10;
    n=7;
    pdata=1;
    [data2,filterdata,kx,kz]=LowPass2(data,cutoff,dx,n,pdata);
    
end
if nargin==1;
	disp('Cutoff frequency must be supplied')
	return
end
if nargin==2;
    dx=1;
    n=7;
end
if nargin==3;
    n=7;
end
if exist('pdata')==0;
    pdata=1;
end
do_pad=1;
if do_pad==1
    org_size=size(data);
    data=([data,fliplr(data);flipud([data,fliplr(data)])]);
end
meandata=nanmean(data(:));
data=data-meandata;
if length(cutoff)==1;
    cutoff(2)=cutoff(1);
end
if length(dx)==1
    dz=dx;
else
    dz=dx(2);
    dx=dx(1);
end
[nz,nx]=size(data);
dkx=1./(nx*dx);
dkz=1./(nz*dz);
kx=dkx*[-nx/2:1:nx/2-1];
kz=dkz*[-nz/2:1:nz/2-1];
Fdata=fftshift(fft2(data));
[kxx,kzz]=meshgrid(kx,kz);
r=sqrt(kxx.^2+kzz.^2);
d_r=(r./cutoff(1));
%filterdata=1./( 1 + (r./cutoff(1)).^(2*n)  );
d_r=sqrt( (kxx./cutoff(1)).^2+(kzz./cutoff(2)).^2);
filterdata=1./( 1 + d_r.^(2*n)  );
data2=real(ifft2(ifftshift(Fdata.*filterdata)));
data=data+meandata;
data2=data2+meandata;
if do_pad==1
    data=data(1:org_size(1),1:org_size(2));
    data2=data2(1:org_size(1),1:org_size(2));
end
if pdata==1,
  subplot(3,2,1)
  imagesc(kx,kz,filterdata);colorbar
  title('filter')
  subplot(3,2,3)
  imagesc(kx,kz,log(abs(Fdata)));title('Freq Spec')
  subplot(3,2,4)
  imagesc(kx,kz,log(abs(Fdata.*filterdata)));title('Freq domain filtering')
  subplot(3,2,5)
  imagesc(data);title('orig data');ca=caxis;colorbar;
  subplot(3,2,6)
  imagesc(data2);title('filtered data');caxis(ca);colorbar;
end
