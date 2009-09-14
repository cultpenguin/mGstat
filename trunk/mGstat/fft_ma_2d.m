% fft_ma_2d : 
% Call : 
%    [out,z]=fft_ma_2d(x,y,Va,options)
%
%    x: array, ex : x=1:1:80:
%    y: array, ex : y=1:1:50:
%    Va: variogram def, ex : Va="1 Sph (10,.4,30)";
% 
%
% "
%   Ravalec, M.L. and Noetinger, B. and Hu, L.Y.},
%   Mathematical Geology 32(6), 2000, pp 701-723
%   The FFT moving average (FFT-MA) generator: An efficient numerical
%   method for generating and conditioning Gaussian simulations
% "  
%
% Example:
%  x=[1:1:50];y=1:1:80;
%  Va='1  Sph(10,.25,30)';
%  [out,z]=fft_ma_2d(x,y,Va);
%  imagesc(x,y,out);colorbar
%
%
%  x=[1:1:50];y=1:1:80;
%  Va='1  Sph(10,.25,30)';
%  [out1,z_rand]=fft_ma_2d(x,y,Va);
%  ii=300:350;
%  z_rand(ii)=randn(size(z_rand(ii)));
%  options.z_rand=z_rand;
%  [out2,z_rand2]=fft_ma_2d(x,y,Va,options);
%  subplot(1,3,1),imagesc(x,y,[out1]);colorbar;axis image;cax=caxis;
%  subplot(1,3,2),imagesc(x,y,[out2]);caxis(cax);colorbar;axis image
%  subplot(1,3,3),imagesc(x,y,[out2-out1]);colorbar;axis image
%



%
function [out,z_rand,options]=fft_ma_2d(x,y,Va,options)


options.null='';
nx=length(x);
ny=length(y);
dx=x(2)-x(1);
dy=y(2)-y(1);
cell=dx;

if ~isstruct(Va);
    Va=deformat_variogram(Va);
end

if isfield(options,'gmean');
    gmean=options.gmean;
else
    gmean=0;
end
if isfield(options,'gvar');
    gvar=options.gvar;
else
    gvar=sum([Va.par1]);
end

if isfield(options,'Nly');
    Nly=options.Nly;
else
    Nly=30;
end

if ~isfield(options,'Nlx');options.Nlx=30;end
if ~isfield(options,'Nly');options.Nly=30;end


% ONLY WORKS FOR ONE SEMIVRAIOHGRAM MODEL !!
par2=Va(1).par2;
h_max=par2(1);
if length(par2)>1
    h_min=h_max*par2(2);
    ang=par2(3);
else
    h_min=h_max;
    ang=0;
end

h_max=h_max/cell;
h_min=h_min/cell;
dx=cell;
cell=1;
nx_org=nx;
ny_org=ny;
nx=nx+options.Nlx*ceil(h_max/cell);
ny=ny+options.Nly*ceil(h_min/cell);

if 2*h_min>cell*ny || 2*h_max>cell*nx
    error('Warning: A range is too long - extend the grid size')
end


a_max=h_max;
a_min=h_min;
ang=ang*(pi/180); % Transform angle into radians
gamma=a_min/a_max; % anistropy factor < 1 (=1 for isotropy)

% Geometry:
x=cell/2:cell:nx*cell-cell/2;
y=cell/2:cell:ny*cell-cell/2;
if ~isfield(options,'C');
    
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
    % calc semiavriogram
    Va2=Va;
    try
        Va2.par2=Va.par2(1)*Va.par2(2);
    end
    options.C=gvar-semivar_synth(Va2,dist);
end

if isfield(options,'z_rand')
    z_rand=options.z_rand;
else
    z_rand=randn(ny,nx);
end


% Gradual Deformation ?
if isfield(options,'lim');
    x0=dx.*(nx-nx_org)/2;
    y0=dy.*(ny-ny_org)/2;
    x0=0;y0=0;
    
    if ~isfield(options,'gdm_step'); options.gdm_step=pi; end
        
    if isfield(options,'pos');
        [options.used]=set_resim_data(x,y,z_rand,options.lim,options.pos+[x0 y0]);
    else
        x0=cell*ceil(rand(1)*nx_org);
        y0=cell*ceil(rand(1)*ny_org);
        options.pos=[x0 y0];
        [options.used]=set_resim_data(x,y,z_rand,options.lim,options.pos);
        [options.used]=set_resim_data(x,y,z_rand,options.lim);
    end
    ii=find(options.used==0);
    z_rand_new=randn(size(z_rand(ii)));
    z_rand(ii) = grad_deform(z_rand(ii),z_rand_new,options.gdm_step);     
end

z=gvar.*z_rand;

options.out1=reshape(real(ifft2(sqrt(cell*fft2(options.C)).*fft2(z))),ny,nx);

out=options.out1(1:ny_org,1:nx_org)+gmean;

options.nx=nx;
options.ny=ny;
options.nx_org=nx_org;
options.ny_org=ny_org;

