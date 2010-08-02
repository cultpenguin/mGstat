function out=FFT_MA_3D(ny,nx,nz,Nly,Nlx,Nlz,cell,h_min,h_max,h_z,gmean,gvar,it)

% The FFT-MA algorithm in 3D
% Call: out=FFT_MA_3D(ny,nx,nz,Nly,Nlx,Nlz,cell,h_min,h_max,h_z,gmean,gvar,it)
% it: 1) Spherical, 2) Exponential, 3) Gaussian
% ny, nx, nz: Number of model parameters in the x, y, and z directions,
% respectively
% Nlx, Nly, Nlz: Extensions of the grid in the x, y, and z directions in 
% order to avoid artefacts due to edge effects. Number of model parameters 
% in the extension = Nlx*range_x/cell, where cell is the size of the cells 
% and range_x is the range i the x-direction.
% h_min, h_max, and h_z, are the ranges in the horizontal (x), vertical (y) and (z) direction.
% gvar: Global variance
% gmean: Global mean

% Knud S. Cordua (June 2009)

if nargin<14
    lim=0;
    r=0;
end
lim=lim/cell;
h_max=h_max/cell;
h_min=h_min/cell;
h_z=h_z/cell;
dx=cell;
cell=1;
Nx=nx;
Ny=ny;
Nz=nz;
nx=nx+Nlx*ceil(h_max/cell);
ny=ny+Nly*ceil(h_min/cell);
nz=nz+Nlz*ceil(h_z/cell);

%if 2*h_min>cell*ny || 2*h_max>cell*nx || 2*h_z>cell*nz
%    error('Warning: A range is too long - extend the grid size')
%end

ang=0;
if h_min>h_max
    disp('Warning:')
    disp('Choose h_min<=h_max because h_max is the direction of maximum continuity.')
    disp('Use the input "ang" to change the direction of maximum continutiy')
end

a_max=h_max;
a_min=h_min;
a_z=h_z;
ang=ang*(pi/180); % Transform angle into radians
gamma=a_min/a_max; % anistropy factor < 1 (=1 for isotropy)

% Geometry:
x=cell/2:cell:nx*cell-cell/2;
y=cell/2:cell:ny*cell-cell/2;
z=cell/2:cell:ny*cell-cell/2;
[X Y Z]=meshgrid(x,y,z);

h_x=X-x(ceil(length(x)/2));
h_y=Y-y(ceil(length(y)/2));
h_z=Z-z(ceil(length(z)/2));
% Transform into rotated coordinates:
h_min=h_x*cos(ang)-h_y*sin(ang);
h_max=h_x*sin(ang)+h_y*cos(ang);
h_zdir=h_z;
% Rescale the ellipse:
h_min_rs=h_min;
h_max_rs=gamma*h_max;
dist=sqrt(h_min_rs.^2+h_max_rs.^2+h_zdir.^2);
if it==1
    dist(find(dist>a_min))=a_min;
end

if it==1 % Spherical
    C=1-(1.5*(dist./a_min)-0.5*(dist./a_min).^3);
elseif it==2 % Exponential
    C=exp(-3*dist./a_min);
elseif it==3 % Gaussian
    C=exp(-3*dist.^2./a_min.^2);
else % Ricker
    dx=1;
    t0=0;
    dt=1.061394451537358e-010;
    time=dist*dt;
    f0=100*10^6;
    C=(1-2*pi^2*f0^2*(time-t0).^2).*exp(-pi^2*f0^2*(time-t0).^2);
end

% figure(1)
% plot(C)

%randn('seed',50)

    z=sqrt(gvar)*randn(ny,nx,nz);


%for i=1:100

    S=fftn(C);
    Z=fftn(z);
    G=sqrt(S);
    out1=G.*Z;
    out3=real(ifftn(out1));
    out4=reshape(out3,ny,nx,nz);
     
%      out1=reshape(real(ifftn(sqrt(fftn(C)).*fftn(z))),ny,nx,nz);
      out=out4(1:Ny,1:Nx,1:Nz)+gmean;
      
%      figure(20),subplot(1,2,1),imagesc(out),drawnow,title(sprintf('%i',i)),caxis([2.5 8.5])
%      if i>1
%          subplot(1,2,2),imagesc(out-out_old),axis image,caxis([-1 1])
%      end
%      out_old=out;
%      pause
% end

