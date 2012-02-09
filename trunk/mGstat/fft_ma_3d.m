% fft_ma_3d :
% Call :
%    [out,z,options,logL]=fft_ma_2d(x,y,z,Va,options)
%
%    x: array, ex : x=1:1:80:
%    y: array, ex : y=1:1:50:
%    z: array, ex : z=1:1:30:
%    Va: variogram def, ex : Va="1 Sph (10)";
%    Va: variogram def, ex : Va="1 Sph (10,30,.5)";
%    Va: variogram def, ex : Va="1 Sph (10,ang1,ang2,ang3,aniso_1,aniso_2)";
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
% % 3D Gaussian simulation
%  x=[1:1:50];y=1:1:80;z=1:30;
%  Va='1  Sph(10,30,.25)';
%  [m,z]=fft_ma_3d(x,y,z,Va);
%
%
% % Sequential Gibbs with 3D FFT_MA
% x=[1:1:50];y=1:1:55;z=1:45;
% options.fac_x=2;options.fac_y=2;options.fac_z=2;
% Va='.001 Nug(0) + 1 Gau(40,30,.25)';
% [m,z_rand,options]=fft_ma_3d(x,y,z,Va,options);
% options.lim=.1;
% for i=1:6;
%    options.z_rand=z_rand;
%    [m_new,z_rand,options]=fft_ma_3d(x,y,z,Va,options);
%    subplot(2,3,i);
%    isosurface(m_new,.6);isosurface(m_new,0);isosurface(m_new,-.6)
%    view([30 40 10]);axis image
% end
%
%
% original (FFT_MA_2D) Knud S. Cordua (June 2009)
% Thomas M. Hansen (September, 2009)
% Jan Frydendall (April, 2011) Zero padding

%
function [out,z_rand,options,logL]=fft_ma_3d(x,y,z,Va,options)


options.null='';
if ~isstruct(Va);Va=deformat_variogram(Va);end
if ~isfield(options,'gmean');options.gmean=0;end
if ~isfield(options,'gvar');options.gvar=sum([Va.par1]);end
if ~isfield(options,'fac_x');options.fac_x=4;end
if ~isfield(options,'fac_y');options.fac_y=options.fac_x;end
if ~isfield(options,'fac_z');options.fac_z=options.fac_y;end

org.nx=length(x);
org.ny=length(y);
org.nz=length(z);

% ?
if length(x)==1; x=[x x+.0001]; end
if length(y)==1; y=[y y+.0001]; end
if length(z)==1; z=[z z+.0001]; end


nx=length(x);
ny=length(y);
nz=length(z);
cell=1;
if nx>1; dx=x(2)-x(1); cell=dx; else dx=1; end
if ny>1; dy=y(2)-y(1); cell=dy; else dy=1; end
if nz>1; dz=z(2)-z(1); cell=dz; else dz=1; end

nx_c=nx*options.fac_x;
ny_c=ny*options.fac_y;
nz_c=nz*options.fac_z;

% COVARIANCE MODEL
if (~isfield(options,'C'))&(~isfield(options,'fftC'));
    x1=dx/2:dx:nx_c*dx-dx/2;
    y1=dy/2:dy:ny_c*dy-dy/2;
    z1=dz/2:dz:nz_c*dz-dz/2;
    [X Y Z]=meshgrid(x1,y1,z1);
    h_x=X-x1(ceil(nx_c/2));
    h_y=Y-y1(ceil(ny_c/2));
    h_z=Z-z1(ceil(nz_c/2));
    
    C=precal_cov([0 0 0],[h_x(:) h_y(:) h_z(:)],Va);
    options.C=reshape(C,ny_c,nx_c,nz_c);
end

if ~isfield(options,'fftC');
    options.fftC=fftn(options.C);
end
% normal devaites
if isfield(options,'z_rand')
    z_rand=options.z_rand;
else
    z_rand=randn(ny_c,nx_c,nz_c);
    %z_rand=gsingle(z_rand);
    
end

%% RESIM
if ~isfield(options,'resim_type');
    options.resim_type=2;
end

if isfield(options,'lim');
    if options.resim_type==1;
        disp(sprintf('%s : UPDATE TO WORK IN 3D',mfilename))
        % resom box_type
        x0=dx.*(nx-nx_c)/2;
        y0=dy.*(ny-ny_c)/2;
        z0=dz.*(ny-nz_c)/2;
        x0=0;y0=0;z0=0;
        options.wrap_around=1;
                
        if isfield(options,'pos');
            [options.used]=set_resim_data(x,y,z_rand,options.lim,options.pos+[x0 y0],options.wrap_around);
        else
            x0=dx*ceil(rand(1)*nx_c); y0=dy*ceil(rand(1)*ny_c);
            %disp(sprintf('x0=%5g %5g  y0=%5g %5g',x0,nx_c*dx,y0,ny_c*dy))
            %x0=cell*ceil(rand(1)*nx); y0=cell*ceil(rand(1)*ny);
            options.pos=[x0 y0];
            [options.used]=set_resim_data([1:nx_c]*dx,[1:ny_c]*dy,z_rand,options.lim,options.pos,options.wrap_around);
            
        end
        ii=find(options.used==0);
        z_rand_new=randn(size(z_rand(ii)));
        z_rand(ii) = z_rand_new;
    else     
        % resim random locations        
        
        n_resim=options.lim(1);
        if n_resim<=1
            % use n_resim as a proportion of all random deviates
            n_resim=n_resim.*prod(size(z_rand));
        end
        n_resim=ceil(n_resim);
        
        n_resim = min([n_resim prod(size(z_rand))]);
        N_all=prod(size(z_rand));
        % find random sample of size 'n_resim'
        ii=randomsample(N_all,n_resim);
                
        z_rand_new=randn(size(z_rand(ii)));
        z_rand(ii) = z_rand_new;
    end
end
    
z=z_rand;
%fftw('planner', 'hybrid');
fftw('planner', 'exhaustive');

%fn=fftn(z);
%out=real(ifftn(sqrt(options.fftC).*fn));
out=real(ifftn(sqrt(options.fftC).*fftn(z)));
out=reshape(out,ny_c,nx_c,nz_c);

% prior likelihood
logL = -.5*sum(z(:).^2);


out=out(1:ny,1:nx,1:nz)+options.gmean;

if org.nx==1; out=out(:,1,:); end
if org.ny==1; out=out(1,:,:); end
if org.nz==1; out=out(:,:,1); end

options.nx=nx;
options.ny=ny;
options.nz=nz;
options.nx_c=nx_c;
options.ny_c=ny_c;
options.nz_c=nz_c;

