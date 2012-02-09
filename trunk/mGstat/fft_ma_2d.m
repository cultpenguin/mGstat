% fft_ma_2d :
% Call :
%    [out,z,options,logL]=fft_ma_2d(x,y,Va,options)
%
%    x: array, ex : x=1:1:80:
%    y: array, ex : y=1:1:50:
%    Va: variogram def, ex : Va="1 Sph (10,30,4)";
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
%  Va='1  Sph(10,30,.25)';
%  [out1,z_rand]=fft_ma_2d(x,y,Va);
%  ii=300:350;
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


% UPDATE TO WORK IN 1D   
% UPDATE TO WORK WITH RESIM

%
function [out,z_rand,options,logL]=fft_ma_2d(x,y,Va,options)

options.null='';
if ~isstruct(Va);Va=deformat_variogram(Va);end
if ~isfield(options,'gmean');options.gmean=0;end
if ~isfield(options,'gvar');options.gvar=sum([Va.par1]);end
if ~isfield(options,'fac_x');options.fac_x=4;end
if ~isfield(options,'fac_y');options.fac_y=options.fac_x;end

org.nx=length(x);
org.ny=length(y);

if length(x)==1; x=[x x+.0001]; end
if length(y)==1; y=[y y+.0001]; end


nx=length(x);
ny=length(y);
cell=1;
if nx>1; dx=x(2)-x(1); cell=dx; else dx=1; end
if ny>1; dy=y(2)-y(1); cell=dy; else dy=1; end

ny_c=ny*options.fac_y;
nx_c=nx*options.fac_x;
%%
% COVARIANCE MODEL
if (~isfield(options,'C'))&(~isfield(options,'fftC'));
    
    
    options.C=zeros(ny_c,nx_c);
    
    iM=1;
    
    if iM==1
        x1=dx/2:dx:nx_c*dx-dx/2;
        y1=dy/2:dy:ny_c*dy-dy/2;
        [X Y]=meshgrid(x1,y1);
        h_x=X-x1(ceil(nx_c/2));
        h_y=Y-y1(ceil(ny_c/2));
        C=precal_cov([0 0],[h_x(:) h_y(:)],Va);
        options.C=reshape(C,ny_c,nx_c);
    else
        for iv=1:length(Va);
            
            % GET HMAX AND HMIN FROM SEMIVARIOGRAM MODEL
            % ONLY WORKS FOR ONE SEMIVRAIOHGRAM MODEL !!
            par2=Va(iv).par2;
            h_max=par2(1);
            if length(par2)>1
                h_min=h_max*par2(3);
                ang=par2(2);
            else
                h_min=h_max;
                ang=0;
            end
            try
                aniso=Va(iv).par2(3);
            catch
                aniso=1;
            end
            ang1=ang*(pi/180);
            
            
            x=dx/2:dx:nx_c*dx-dx/2;
            y=dy/2:dy:ny_c*dy-dy/2;
            [X Y]=meshgrid(x,y);
            h_x=X-x(ceil(nx_c/2));
            h_y=Y-y(ceil(ny_c/2));
            
            % Transform into rotated coordinates:
            h_min=h_x*cos(ang1)-h_y*sin(ang1);
            h_max=h_x*sin(ang1)+h_y*cos(ang1);
            
            % Rescale the ellipse:
            h_min_rs=h_min;
            h_max_rs=aniso*h_max;
            dist=sqrt(h_min_rs.^2+h_max_rs.^2);
            
            % calc semiavriogram
            Va2=Va(iv);
            try
                Va2.par2=Va(iv).par2(1)*Va(iv).par2(3);
            end
            options.C=options.C+semivar_synth(Va2,dist);
        end
        options.C=options.gvar-options.C;
    end
end

if ~isfield(options,'fftC');
    options.fftC=fft2(options.C);
end
% normal devaites
if isfield(options,'z_rand')
    z_rand=options.z_rand;
else
    z_rand=randn(ny_c,nx_c);
    %z_rand=gsingle(z_rand);
    
end

%% RESIM
if ~isfield(options,'resim_type');
    options.resim_type=2;
end

if isfield(options,'lim');
    if options.resim_type==1;
        % resom box_type
        x0=dx.*(nx-nx_c)/2;
        y0=dy.*(ny-ny_c)/2;
        x0=0;y0=0;
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
out=reshape(real(ifft2(sqrt(options.fftC).*fft2(z))),ny_c,nx_c);
out1_complex=reshape((ifft2(sqrt(options.fftC).*fft2(z))),ny_c,nx_c);

% prior likelihood
logL = -.5*sum(z(:).^2);


out=out(1:ny,1:nx)+options.gmean;
%out=options.out1(1:ny,1:nx).*sqrt(options.gvar)+options.gmean;

if org.nx==1; out=out(:,1); end
if org.ny==1; out=out(1,:); end

options.nx=nx;
options.ny=ny;
options.nx_c=nx_c;
options.ny_c=ny_c;

