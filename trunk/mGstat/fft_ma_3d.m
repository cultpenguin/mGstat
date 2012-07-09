% fft_ma_3d :
% Call :
%    [out,z,options,logL]=fft_ma_3d(x,y,z,Va,options)
%
%    x: array, ex : x=1:1:80:
%    y: array, ex : y=1:1:50:
%    z: array, ex : z=1:1:50:
%    Va: variogram def, ex : Va="1 Sph (10,30,.25)";
%
%    options.gmean
%    options.gvar
%    options.pad_x : Padding in x-direction (number of pixels [def=nx])
%    options.pad_y : Padding in y-direction (number of pixels [def=ny])
%    options.pad_z : Padding in z-direction (number of pixels [def=nz])
%    options.wx,options.wy,options.wz : wraparound padding around the simulation area
%       when using sequential Gibbs simulation.
%       [def, options.wx=max(range)/dx]
%       [def, options.wy=max(range)/dy]
%       [def, options.wz=max(range)/dz]
%
%
% "
%   Ravalec, M.L. and Noetinger, B. and Hu, L.Y.},
%   Mathematical Geology 32(6), 2000, pp 701-723
%   The FFT moving average (FFT-MA) generator: An efficient numerical
%   method for generating and conditioning Gaussian simulations
% "
%
% Examples:
% % 1D
%  x=1:1:512;y=0;z=0;
%  Va='1 Gau(20)';
%  [out,z]=fft_ma_3d(x,y,z,Va);
%  plot(x,out);colorbar
%
% % 2D
%  x=[1:1:50];y=1:1:80;z=0;
%  direction=30; % 30 degrees from north
%  h_max=10;
%  h_min=5;
%  aniso=h_min/h_max;
%  Va='1  Sph(10,30,5/10)';
%  [out,z]=fft_ma_3d(x,y,z,Va);
%  imagesc(x,y,out);colorbar
%
%
%  x=[1:1:50];y=1:1:80;z=0;
%  Va='1  Sph(10,30,.25)';
%  [out1,z_rand]=fft_ma_2d(x,y,Va);
%  ii=10000:20000;
%  z_rand(ii)=randn(size(z_rand(ii)));
%  options.z_rand=z_rand;
%  [out2,z_rand2]=fft_ma_3d(x,y,z,Va,options);
%  subplot(1,3,1),imagesc(x,y,[out1]);colorbar;axis image;cax=caxis;
%  subplot(1,3,2),imagesc(x,y,[out2]);caxis(cax);colorbar;axis image
%  subplot(1,3,3),imagesc(x,y,[out2-out1]);colorbar;axis image
%
% % 3D
%  x=[1:1:50];y=1:1:80;z=1:30;
%  Va='1  Sph(10,30,.25)';
%  [m,z]=fft_ma_3d(x,y,z,Va);
%  isosurface(m,.6);isosurface(m,0);isosurface(m,-.6)
%  view([30 40 10]);axis image


% Using proper semivariogram anisotropy specification (Feb, 2012)
% original (FFT_MA_2D) Knud S. Cordua (June 2009)
% Thomas M. Hansen (September, 2009)
% Jan Frydendall (April, 2011) Zero padding


% UPDATE TO WORK WITH RESIM

%
function [out,z_rand,options,logL]=fft_ma_3d_news(x,y,z,Va,options)

if nargin==0
    x=[1:1:32];y=1:1:32;z=1:32;
    Va='1  Sph(10,30,.25)';
    options.wx=0;
    options.wy=0;
    options.wz=0;
    options.pad_x=0;
    options.pad_y=0;
    options.pad_z=0;
    [m,z_rand,options]=fft_ma_3d_new(x,y,z,Va);
    isosurface(m,.6);isosurface(m,0);isosurface(m,-.6)
    view([30 40 10]);axis image
    return
end    

options.null='';
if ~isstruct(Va);Va=deformat_variogram(Va);end
if ~isfield(options,'wrap_around');options.wrap_around=1;end
if ~isfield(options,'gmean');options.gmean=0;end
if ~isfield(options,'gvar');options.gvar=sum([Va.par1]);end
nx=length(x);
ny=length(y);
nz=length(z);
if nx>1; dx=x(2)-x(1);  else dx=1; end
if ny>1; dy=y(2)-y(1);  else dy=1; end
if nz>1; dz=z(2)-z(1);  else dz=1; end
if isfield(options,'pad');
    if length(options.pad)==1, options.pad=[1 1 1].*options.pad;end
    try;options.pad_x=options.pad(1);end
    try;options.pad_y=options.pad(2);end
    try;options.pad_z=options.pad(3);end
end
if ~isfield(options,'pad_x');options.pad_x=nx-1;end
if ~isfield(options,'pad_y');options.pad_y=ny-1;end
if ~isfield(options,'pad_z');options.pad_z=nz-1;end
if ~isfield(options,'padpow2');options.padpow2=1;end
if isfield(options,'w');
    if length(options.w)==1, options.w=[1 1 1].*options.w;end
    try;options.wx=options.w(1);end
    try;options.wy=options.w(2);end
    try;options.wz=options.w(3);end
end
if ~isfield(options,'wx');
    options.wx = 2*ceil(max([Va.par2])./dx);
end
if ~isfield(options,'wy');
    options.wy = 2*ceil(max([Va.par2])./dy);
end
if ~isfield(options,'wz');
    options.wz = 2*ceil(max([Va.par2])./dz);
end

if length(x)==1; x=[x x+.0001]; end
if length(y)==1; y=[y y+.0001]; end
if length(z)==1; z=[z z+.0001]; end

org.nx=nx;
org.ny=ny;
org.nz=nz;

% padding size (before padding to size 2^n)
nx_c=nx+options.pad_x;
ny_c=ny+options.pad_y;
nz_c=nz+options.pad_z;

%% SETUP  COVARIANCE MODEL
if (~isfield(options,'C'))&(~isfield(options,'fftC'));
    
    if (options.padpow2==1)
        nx_c=2.^nextpow2(nx_c);
        ny_c=2.^nextpow2(ny_c);
        nz_c=2.^nextpow2(nz_c);
    end
    
    x1=[0:1:(nx_c-1)].*dx;
    y1=[0:1:(ny_c-1)].*dy;
    z1=[0:1:(nz_c-1)].*dz;
       
    if (~isfield(options,'X'))|(~isfield(options,'Y'))|(~isfield(options,'Z'));
        [options.X options.Y options.Z]=meshgrid(x1,y1,z1);
    end
    
    if nx>1, h_x=options.X-x1(ceil(nx_c/2)+1);else;h_x=options.X;end
    if ny>1, h_y=options.Y-y1(ceil(ny_c/2)+1);else;h_y=options.Y;end
    if nz>1, h_z=options.Z-z1(ceil(nz_c/2)+1);else;h_z=options.Z;end
    
    if nz==1;
        C=precal_cov([0 0],[h_x(:) h_y(:)],Va);
    elseif ny==0;
        C=precal_cov([0 0],[h_x(:) h_z(:)],Va);
    elseif nx==0;
        C=precal_cov([0 0],[h_y(:) h_z(:)],Va);
    else
        C=precal_cov([0 0 0],[h_x(:) h_y(:) h_z(:)],Va);
    end
    options.C=reshape(C,ny_c,nx_c,nz_c);
end

%% COMPUTE FFT and PAD
if ~isfield(options,'fftC');
    options.fftC=fftn(fftshift(options.C));
end

%% normal deviates
if isfield(options,'z_rand')
    % use given set
    z_rand=options.z_rand;
else
    % create a new set
    z_rand=randn(size(options.fftC));
end

%% RESIMULATION
if ~isfield(options,'resim_type');
    options.resim_type=2;
end

if isfield(options,'lim');
    
    % use a border zone correspoding to twice the size of the
    % maximum range
    %options.wx = 2*ceil(max([Va.par2])./dx);
    %options.wy = 2*ceil(max([Va.par2])./dy);
    
    % make sure we only pad around simulation
    % box, if needed
    if options.wx > (size(z_rand,2)-nx);options.wx=0;end
    if options.wy > (size(z_rand,1)-ny);options.wy=0;end
    if options.wz > (size(z_rand,3)-nz);options.wz=0;end
           
    if options.resim_type==1;
        % BOX TYPE RESIMULATION 
        if isfield(options,'pos');
            % NEXT LINE MAY BE PROBLEMATIC USING NEIGHBORHOODS
            x0=dx.*(nx-nx_c)/2;
            y0=dy.*(ny-ny_c)/2;
            z0=dy.*(nz-nz_c)/2;
            x0=0;y0=0;z0=0;
            %           options.wrap_around=1;
            [options.used]=set_resim_data_3d(x,y,z,z_rand,options.lim,options.pos+[x0 y0 z0],options.wrap_around);
        else
            % CHOOSE CENTER OF BOX AUTOMATICALLY
            
            x0=ceil((rand(1)*(nx+options.wx)))-ceil(options.wx/2);
            y0=ceil((rand(1)*(ny+options.wy)))-ceil(options.wy/2);
            z0=ceil((rand(1)*(nz+options.wz)))-ceil(options.wz/2);
            
            if x0<1; x0=size(z_rand,2)+x0;end
            if y0<1; y0=size(z_rand,1)+y0;end
            if z0<1; z0=size(z_rand,3)+z0;end
            if x0>size(z_rand,2); x0=x0-size(z_rand,2);end
            if y0>size(z_rand,1); y0=y0-size(z_rand,1);end
            if z0>size(z_rand,3); z0=z0-size(z_rand,3);end
            
            x0=dx*x0; 
            y0=dy*y0;
            z0=dz*z0;
          
            options.pos=[x0 y0 z0];
            [options.used]=set_resim_data_3d([1:size(z_rand,2)]*dx,[1:size(z_rand,1)]*dy,[1:size(z_rand,3)]*dz,z_rand,options.lim,options.pos,options.wrap_around,options.X,options.Y,options.Z);
            
        end
        ii=find(options.used==0);
        z_rand_new=randn(size(z_rand(ii)));
        z_rand(ii) = z_rand_new;
    else 
        % RANDOM SET TYPE RESIMULATION 
        
        % MAKE SURE ONLY TO SELECT RESIM DATA
        % WITHIN (and close to) SIMULATION AREA
        
        n_resim=options.lim(1);
        if n_resim<=1
            % use n_resim as a proportion of all random deviates
            n_resim=n_resim.*prod(size(z_rand));
        end
        n_resim=ceil(n_resim);
        n_resim = min([n_resim prod(size(z_rand))]);
        
        N_all=(nx+options.wx)*(ny+options.wy)*(nz+options.wz);
        
        n_resim = min([n_resim N_all]);
        
        % Select random set of nodes within simulation grid !
        ii=randomsample(N_all,n_resim);
        
        z_rand_new=randn(size(z_rand(ii)));
        [ix,iy,iz]=ind2sub([ny+options.wy,nx+options.wx,nz+options.wz],ii);
        
        for k=1:length(ii);
            
            x0=round(ix(k))-ceil(options.wx/2);
            y0=round(iy(k))-ceil(options.wx/2);
            z0=round(iz(k))-ceil(options.wz/2);
            
            if x0<1; x0=size(z_rand,2)+x0;end
            if y0<1; y0=size(z_rand,1)+y0;end
            if z0<1; z0=size(z_rand,3)+z0;end
            if x0>size(z_rand,2); x0=x0-size(z_rand,2);end
            if y0>size(z_rand,1); y0=y0-size(z_rand,1);end
            if z0>size(z_rand,3); z0=z0-size(z_rand,3);end
            
            z_rand(y0,x0,z0)=z_rand_new(k);
        end
    end
end
    
% inverse FFT

out=(ifftn( sqrt((options.fftC)).*fftn(z_rand) ));
options.out=out;

out=real(out(1:ny,1:nx,1:nz))+options.gmean;
if org.nx==1; out=out(:,1,:); end
if org.ny==1; out=out(1,:,:); end
if org.nz==1; out=out(:,:,1); end

% Prior Likelihood
logL = -.5*sum(z_rand(:).^2);

options.nx=nx;
options.ny=ny;
options.nz=nz;
options.nx_c=nx_c;
options.ny_c=ny_c;
options.nz_c=nz_c;

