% VONK2D.M : 2D Von Karman Distribution
%
% Call : [randdata,x,z,data,expcorr]=vonk2d(rseed,dx,dz,ax,az,ix,iz,pop,med,nu,vel,frac)
%
% rseed : Random Seed number
% dx,dz : Spatial distance
% ax,az : Horizontal, vertical lengthscale
% ix,iz : size of model in same scale as ax,az
% nu    : Hurst Number
%
% pop   : Population, [1]:Gaussian [2]:PDF
% med   : Medium    , [1]:Gaussian [2]:Exponential [3]: Von Karman 
%                     [4]:Pink     [5]:Brown
% vel   : Scalar or vector of velocities, For pop=pdf,v(1) is used as
%                                         +/-max velocity of input field
% frac  : fraction assigned to each velocity (normalized), same size
%         as vel   
%
% (C) 1998-2001 Thomas Mejer Hansen (tmh@gfy.ku.dk)
% UPDATED APR 05 1999 /TMH
% Octave 2.0.15 and Matlab 5.3 compliant
% 
function [rdata,x,z,data,expcorr]=vonk2d(rseed,dx,dz,ax,az,ix,iz,pop,med,nu,vel,frac)

if nargin==0,
  
 help vonk2d 
  
 rseed=56;
 dx=25;
 dz=dx;
 ax=750;
 az=200;
 nu=.6;
 ix=6000;
 iz=6000;
 pop=2;
 med=3;
 vel=[6000 6600 7000 2000 5000];
 frac=[.5 .5 .5 .3 .1];
end

if nargin==10,
  frac=[1,2,3]; % the same as [.16 .33 .5]
  vel=[2000,3000,4000];
end

 if pop==1, % POP=GAUSSIAN
   D=3-nu;
 elseif pop==2 % POP=PDF
   D=3-nu/2;
 end
 
 
nx=ceil(ix/dx);
nz=ceil(iz/dz);
%disp([' VONK2D : 2D RANDOM MEDIA GENERATOR'])
%disp([' Using (nx,nz)=(',num2str(nx),',',num2str(nz),')'])

if (nx/2)~=round(nx/2), ddx=1; nx=nx+ddx; else ddx=0; end
if (nz/2)~=round(nz/2), ddz=1; nz=nz+ddz; else ddz=0; end
  
 
% SPACEDOMAIN GRID
%[x,z]=meshgrid(dx*[-nx/2:1:nx/2-1],dz*[-nz/2:1:nz/2-1]);
x=[1:1:nx]*dx;
z=[1:1:nz]*dz;

% WAVENUMBER DOMAIN GRID
dkx=1/(nx*dx);
dkz=1/(nz*dz);
[kx,kz]=meshgrid(2*pi*dkx*[-nx/2:1:nx/2-1],2*pi*dkz*[-nz/2:1:nz/2-1]);

k=sqrt(kx.^2.*ax.^2+kz.^2.*az.^2);



if med==1, 
  %
  % Gaussian Chh
  %
  % SQRT of the FOURIER TRANSROMF OF Gaussian CORR fkt.
  %disp([' Calculating filter : Chh=Gaussian'])
  expcorr=((ax*az)/2).*exp(-(k.^2./4));          % (Exact F(C_hh(x))
  expcorr=expcorr./max(max(expcorr));        % normalizing sqr(F(C_hh))
  expcorr=sqrt(expcorr);                     %
end

if med==2, 
  %
  % Exponential Chh
  %
  % SQRT of the FOURIER TRANSROMF OF exp CORR fkt.
  %disp([' Calculating filter : Chh=exponential'])
  %expcorr=(ax^2+az^2)./((1+k.^2).^(1.5));    % (Exact F(C_hh(x))
  expcorr=1./((1+k.^2).^(1.5));    % (Exact F(C_hh(x))
  expcorr=expcorr./max(max(expcorr));        % normalizing sqr(F(C_hh))
  expcorr=sqrt(expcorr);                     %
end

if med==3, 
  %
  % von Karman
  %
  % SQRT of the FOURIER TRANSROMF OF vonk CORR fkt.
  %disp([' Calculating filter : Chh=vonKarman'])  
  %disp([' Fractal Dimension : ',num2str(D)])
  %expcorr=((ax*az)/2)./((1+k.^2).^(nu+1));          % (Exact F(C_hh(x))
  expcorr=1./((1+k.^2).^(nu+1));          % (Exact F(C_hh(x))
  expcorr=expcorr./max(max(expcorr));        % normalizing sqr(F(C_hh))
  expcorr=sqrt(expcorr);                     %
end


  
% DATA
%
rand('seed',rseed);
data=(rand(nz,nx)-.5);


% GOING TO FOURIER DOMAIN
%disp([' Going to Fourier Domain(fft)'])
fdata=fftshift(fft2(data));

% MULTIPLYING fdata by sqrt(C_hh)
%disp([' Applying filter'])
newfdata=fdata.*expcorr;

%FROM FOURIER TO SPACE DOMAIN
%disp([' Going to spacedomain (ifft)'])
randdata=real(ifft2(fftshift(newfdata)));
rdata=randdata;
return
if pop==1,
  % scaling filed according to vel
  rdata=randdata.*2 *vel(1);
  data=data.*2 *vel(1);
end

if pop==2
  %disp([' Using pdf population'])
  frac=cumsum(frac./sum(frac)); % normalize and cumsum
  %disp(' Sorting data')
  sdata=sort(randdata(:));
  nn=nx*nz;
 
  % Calculate critical values in randdata to resemble fraction
  fraclimit=zeros(length(frac+1),1);
  fraclimit(1)=sdata(1);
  
  for n=1:length(frac); fraclimit(n+1)=sdata(round(nn*frac(n))); end

  fraclimit(1) = fraclimit(1)- 0.1*abs(fraclimit(1));
  fraclimit(length(fraclimit)) = fraclimit(length(fraclimit)) + 0.1*abs(fraclimit(length(fraclimit)));
  
  rdata=zeros(size(randdata));
  
  for n=1:length(frac), 
    %disp([' Assigning velocities to fraction',num2str(n)])
   
    % OLD SLOW SOLUTION
    % [x1,z1]=find(randdata>fraclimit(n) & randdata<fraclimit(n+1) ;
    % ixz=find(randdata>fraclimit(n) & randdata<fraclimit(n+1) ); 
 
    mask = randdata>fraclimit(n) & randdata<=fraclimit(n+1);
    rdata = rdata + mask*vel(n);
  end  
end

rdata=rdata(1:1:nz-ddz,1:1:nx-ddx);

if nargin==0,
  imagesc(x,z,rdata);
  title(['rseed=',num2str(rseed),', dx=dz=',num2str(dx),', ax=',num2str(ax),', az=',num2str(az),', med=',num2str(med),', pop=',num2str(pop),',  D=',num2str(D)])
    colorbar;colormap(copper)
%  rseed,dx,dz,ax,az,ix,iz,pop,med,nu,vel,frac)
end


