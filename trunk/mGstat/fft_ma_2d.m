% fft_ma_2d :
% Call :
%    [out,z,options,logL]=fft_ma_2d(x,y,Va,options)
%
%    x: array, ex : x=1:1:80:
%    y: array, ex : y=1:1:50:
%    Va: variogram def, ex : Va="1 Sph (10,30,.25)";
%
%    options.gmean
%    options.gvar
%    options.pad_x : Padding in x-direction (number of pixels [def=nx])
%    options.pad_y : Padding in y-direction (number of pixels [def=ny])
%    options.wx,options.wx : wraparound padding around the simulation area
%       when using sequential Gibbs simulation.
%       [def, options.wx=max(range)/dx,options.wy=max(range)/dy]
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
%  x=1:1:512;y=1;
%  Va='1 Gau(20)';
%  [out,z]=fft_ma_2d(x,y,Va);
%  plot(x,out);colorbar
%
% % 2D
%  x=[1:1:50];y=1:1:80;
%  direction=30; % 30 degrees from north
%  h_max=10;
%  h_min=5;
%  aniso=h_min/h_max;
%  Va='1  Sph(10,30,5/10)';
%  [out,z]=fft_ma_2d(x,y,Va);
%  imagesc(x,y,out);colorbar
%
%
%  x=[1:1:50];y=1:1:80;
%  Va='1  Sph(10,30,.25)';
%  [out1,z_rand]=fft_ma_2d(x,y,Va);
%  ii=10000:20000;
%  z_rand(ii)=randn(size(z_rand(ii)));
%  options.z_rand=z_rand;
%  [out2,z_rand2]=fft_ma_2d(x,y,Va,options);
%  subplot(1,3,1),imagesc(x,y,[out1]);colorbar;axis image;cax=caxis;
%  subplot(1,3,2),imagesc(x,y,[out2]);caxis(cax);colorbar;axis image
%  subplot(1,3,3),imagesc(x,y,[out2-out1]);colorbar;axis image
%
% Using proper semivariogram anisotropy specification (Feb, 2012)
% original (FFT_MA_2D) Knud S. Cordua (June 2009)
% Thomas M. Hansen (September, 2009)
% Jan Frydendall (April, 2011) Zero padding


% UPDATE TO WORK WITH RESIM

%
function [out,z_rand,options,logL]=fft_ma_2d(x,y,Va,options)

if nargin==0
    x=[1:1:50];y=1:1:80;
    Va='1  Sph(10,30,.25)';
    [out1,z_rand]=fft_ma_2d(x,y,Va);
    ii=1:(prod(size(z_rand))/4);
    z_rand(ii)=randn(size(z_rand(ii)));
    options.z_rand=z_rand;
    options.pad_x=0;
    options.pad_y=0;
    [out2,z_rand2,options]=fft_ma_2d(x,y,Va,options);
    subplot(1,3,1),imagesc(x,y,[out1]);colorbar;axis image;cax=caxis;
    subplot(1,3,2),imagesc(x,y,[out2]);caxis(cax);colorbar;axis image
    subplot(1,3,3),imagesc(x,y,[out2-out1]);colorbar;axis image
    out=out2;
    return
end
options.null='';
if ~isfield(options,'resim_type'); options.resim_type=2;end
if ~isstruct(Va);Va=deformat_variogram(Va);end
if ~isfield(options,'wrap_around');options.wrap_around=1;end
if ~isfield(options,'gmean');options.gmean=0;end
if ~isfield(options,'gvar');options.gvar=sum([Va.par1]);end
nx=length(x);
ny=length(y);
if nx>1; dx=x(2)-x(1);  else dx=1; end
if ny>1; dy=y(2)-y(1);  else dy=1; end
if isfield(options,'pad');
    if length(options.pad)==1, options.pad=[1 1].*options.pad;end
    try;options.pad_x=options.pad(1);end
    try;options.pad_y=options.pad(2);end
end
if ~isfield(options,'pad_x');options.pad_x=nx-1;end
if ~isfield(options,'pad_y');options.pad_y=ny-1;end
if ~isfield(options,'padpow2');options.padpow2=0;end
if isfield(options,'w');    
    if length(options.w)==1, options.w=[1 1].*options.w;end
    try;options.wx=options.w(1);end
    try;options.wy=options.w(2);end
end
if ~isfield(options,'wx');
    if options.resim_type==1
        options.wx=0;
    else
        options.wx = 2*ceil(semivar_get_max_range(Va)./dx);
    end
end
if ~isfield(options,'wy');
    if options.resim_type==1
        options.wy=0;
    else
        options.wy = 2*ceil(semivar_get_max_range(Va)./dy);
    end
end

if length(x)==1; x=[x x+.0001]; end
if length(y)==1; y=[y y+.0001]; end

org.nx=nx;
org.ny=ny;

ny_c=ny+options.pad_y;
nx_c=nx+options.pad_x;
x_all=[0:1:(nx_c-1)].*dx+x(1);
y_all=[0:1:(ny_c-1)].*dy+y(1);

%% REMOVE OLD COVARIANCE OF options.constant_C=0
if (isfield(options,'constant_C'));
    if options.constant_C==0;
        try;options=rmfield(options,'C');end
        try;options=rmfield(options,'fftC');end
    end
end

%% SETUP  COVARIANCE MODEL
if (~isfield(options,'C'))&(~isfield(options,'fftC'));
    
    if (options.padpow2==1)
        nx_c=2.^nextpow2(nx_c);
        ny_c=2.^nextpow2(ny_c);
    end
    
    x1=[0:1:(nx_c-1)].*dx;
    y1=[0:1:(ny_c-1)].*dy;
           
    if (~isfield(options,'X'))|(~isfield(options,'Y'));
        [options.X options.Y]=meshgrid(x1,y1);
    end
    if nx>1, h_x=options.X-x1(ceil(nx_c/2)+1);else;h_x=options.X;end
    if ny>1, h_y=options.Y-y1(ceil(ny_c/2)+1);else;h_y=options.Y;end
  
    C=precal_cov([0 0],[h_x(:) h_y(:)],Va);
    options.C=reshape(C,ny_c,nx_c);
    
end

%% COMPUTE FFT and PAD
if ~isfield(options,'fftC');
    options.fftC=fft2(fftshift(options.C));
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

if isfield(options,'lim');
     % use a border zone correspoding to twice the size of the
    % maximum range
    
    % make sure we only pad around simulation
    % box, if needed
    %if options.wx > (size(z_rand,2)-nx);options.wx=0,end
    %if options.wy > (size(z_rand,1)-ny);options.wy=0;end
    %keyboard
    if options.wx > (size(z_rand,2)-nx);options.wx=(size(z_rand,2)-nx);end
    if options.wy > (size(z_rand,1)-ny);options.wy=(size(z_rand,1)-ny);end
    if (options.resim_type==1)|(options.resim_type==3)
        % BOX TYPE RESIMULATION
        
        if isfield(options,'pos');
            [options.used]=set_resim_data(x_all,y_all,z_rand,options.lim,options.pos,options.wrap_around);
        else

            % CHOOSE CENTER OF BOX AUTOMATICALLY
            
            % wx, wy, allow selecting from the center also in a area just
            % outside the simulation area, the border zone. This is done to ensure that
            % nodes at the edge of the simulation error are allowe to vary.
            
            x0=ceil((rand(1)*(nx+2*options.wx)))-ceil(options.wx);
            y0=ceil((rand(1)*(ny+2*options.wy)))-ceil(options.wy);
            if x0<1; x0=size(z_rand,2)+x0;end
            if y0<1; y0=size(z_rand,1)+y0;end
            if x0>size(z_rand,2); x0=x0-size(z_rand,2);end
            if y0>size(z_rand,1); y0=y0-size(z_rand,1);end
             
            % we do not use options.pos, but options.pos_used, such that 
            % opions.pos is not fixed for for subsequent calls top fft_ma
            options.pos_used=[x_all(x0) y_all(y0)];    

            [options.used]=set_resim_data([1:size(z_rand,2)]*dx,[1:size(z_rand,1)]*dy,z_rand,options.lim,options.pos_used,options.wrap_around);

            %% random selection within box
            if options.resim_type==3;
                ii=find(options.used==0);
                nii=length(ii);
                
                pert_proc_in_box=0.1; %numbe of hard data in box to perturb
                i_random=randomsample(nii,ceil(pert_proc_in_box*nii));
                options.used(ii(i_random))=1;
                
            end
            
            
        end
        ii=find(options.used==0);
        z_rand_new=randn(size(z_rand(ii)));
        z_rand(ii) = z_rand_new;
        
    else
        % RANDOM SET TYPE RESIMULATION
        
        n_resim=options.lim(1);
        if n_resim<=1
            % use n_resim as a proportion of all random deviates
            n_resim=n_resim.*prod(size(z_rand));
        end
        n_resim=ceil(n_resim);
        
        n_resim = min([n_resim prod(size(z_rand))]);
        
        % ADD PADDING !!!!
        N_all=(nx+options.wx)*(ny+options.wy);
        
        n_resim = min([n_resim N_all]);
        
        ii=randomsample(N_all,n_resim);
        
        z_rand_new=randn(size(z_rand(ii)));
        [iy,ix]=ind2sub([ny+options.wy,nx+options.wx],ii);
        for k=1:length(ii);
            
            x0=round(ix(k))-ceil(options.wx/2);
            y0=round(iy(k))-ceil(options.wy/2);
            
            if x0<1; x0=size(z_rand,2)+x0;end
            if y0<1; y0=size(z_rand,1)+y0;end
            if x0>size(z_rand,2); x0=x0-size(z_rand,2);end
            if y0>size(z_rand,1); y0=y0-size(z_rand,1);end

            z_rand(y0,x0)=z_rand_new(k);
        
        end
    end
end

% Inverse FFT
%out=(ifft2( sqrt((options.fftC)).*fft2(z_rand,options.nf(1),options.nf(2)) ));
out=(ifft2( sqrt((options.fftC)).*fft2(z_rand) ));
options.out=out;

out=real(out(1:ny,1:nx))+options.gmean;
if org.nx==1; out=out(:,1); end
if org.ny==1; out=out(1,:); end

% Prior Likelihood
logL = -.5*sum(z_rand(:).^2);

options.nx=nx;
options.ny=ny;
options.nx_c=nx_c;
options.ny_c=ny_c;

