function [out z pos]=FFT_MA_2D(ny,nx,Nly,Nlx,cell,h_min,h_max,gmean,gvar,func,lim,r,z)

% The FFT-MA algorithm in 2D
% Call: out=FFT_MA_2D(ny,nx,cell,h_min,h_max,gmean,gvar,func,lim,r,z);
% mode: 1) Spherical, 2) Exponential, 3) Gaussian
% r is a number beteen 0 and pi/2
% lim is a 1x2 array
% gvar
% gmean
% h_min
% h_max
% cell
% Knud S. Cordua (June 2009)

if nargin<11
    lim=0;
    r=0;
end
lim=lim/cell;
h_max=h_max/cell;
h_min=h_min/cell;
dx=cell;
cell=1;
Nx=nx;
Ny=ny;
nx=nx+Nlx*ceil(h_max/cell);
ny=ny+Nly*ceil(h_min/cell);

if 2*h_min>cell*ny || 2*h_max>cell*nx
    error('Warning: A range is too long - extend the grid size')
end

ang=0;
if h_min>h_max
    disp('Warning:')
    disp('Choose h_min<=h_max because h_max is the direction of maximum continuity.')
    disp('Use the input "ang" to change the direction of maximum continutiy')
end

a_max=h_max;
a_min=h_min;
ang=ang*(pi/180); % Transform angle into radians
gamma=a_min/a_max; % anistropy factor < 1 (=1 for isotropy)

% Geometry:
x=cell/2:cell:nx*cell-cell/2;
y=cell/2:cell:ny*cell-cell/2;
[X Y]=meshgrid(x,y);

h_x=X-x(ceil(length(x)/2));
h_y=Y-y(ceil(length(y)/2));
% Transform into rotated coordinates:
h_min=h_x*cos(ang)-h_y*sin(ang);
h_max=h_x*sin(ang)+h_y*cos(ang);
% Rescale the ellipse:
h_min_rs=h_min;
h_max_rs=gamma*h_max;
dist=sqrt(h_min_rs.^2+h_max_rs.^2);
if func==1
    dist(find(dist>a_min))=a_min;
end

if func==1 % Spherical
    C=1-(1.5*(dist./a_min)-0.5*(dist./a_min).^3);
elseif func==2 % Exponential
    C=exp(-3*dist./a_min);
elseif func==3 % Gaussian
    C=exp(-3*dist.^2./a_min.^2);
else % Ricker
    dx=1;
    t0=0;
    dt=1.061394451537358e-010;
    time=dist*dt;
    f0=100*10^6;
    C=(1-2*pi^2*f0^2*(time-t0).^2).*exp(-pi^2*f0^2*(time-t0).^2);
end

figure(1)
plot(C)

%randn('seed',50)
if nargin<13
    z=sqrt(gvar)*randn(ny,nx);
end

%for i=1:100
    if sum(lim)>0

    pos(1)=round(1+rand(1)*(Nx-1));
    pos(2)=round(1+rand(1)*(Ny-1));
    [xx,yy]=meshgrid(1:nx,1:ny);
    used=xx.*0;
    used(abs(xx-pos(1))<lim(1) & abs(yy-pos(2))<lim(2))=1;
    notused=xx.*0+1;
    notused(abs(xx-pos(1))<lim(1) & abs(yy-pos(2))<lim(2))=0;
    z=z.*notused+used.*z*cos(r)+used.*randn(size(used)).*used*sin(r)*sqrt(gvar);
    pos=pos*dx;
    end

%    S=fft2(C);
%    Z=fft2(z);
%    G=sqrt(cell*S);
%    out1=G.*Z;
%    out3=fftshift(real(ifft2(out1)),1);
%    out3=real(ifft2(out1));
%    out4=reshape(out3,ny,nx);
     
      out1=reshape(real(ifft2(sqrt(cell*fft2(C)).*fft2(z))),ny,nx);
      out=out1(1:Ny,1:Nx)+gmean;
      
%      figure(20),subplot(1,2,1),imagesc(out),drawnow,title(sprintf('%i',i)),caxis([2.5 8.5])
%      if i>1
%          subplot(1,2,2),imagesc(out-out_old),axis image,caxis([-1 1])
%      end
%      out_old=out;
%      pause
% end

