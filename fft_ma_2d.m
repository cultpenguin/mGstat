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
if ~isstruct(Va);Va=deformat_variogram(Va);end
if ~isfield(options,'gmean');options.gmean=0;end
if ~isfield(options,'gvar');options.gvar=sum([Va.par1]);end
nx=length(x);
ny=length(y);
if nx>1; dx=x(2)-x(1);  else dx=1; end
if ny>1; dy=y(2)-y(1);  else dy=1; end
if ~isfield(options,'pad_x');options.pad_x=nx;end
if ~isfield(options,'pad_y');options.pad_y=ny;end
if ~isfield(options,'wx');
    options.wx = 2*ceil(max([Va.par2])./dx);
end
if ~isfield(options,'wy');
    options.wy = 2*ceil(max([Va.par2])./dy);
end

if length(x)==1; x=[x x+.0001]; end
if length(y)==1; y=[y y+.0001]; end

org.nx=nx;
org.ny=ny;

ny_c=ny+options.pad_y;
nx_c=nx+options.pad_x;

%% SETUP  COVARIANCE MODEL
if (~isfield(options,'C'))&(~isfield(options,'fftC'));
    
    
    options.C=zeros(ny_c,nx_c);
    
    iM=1;
    
    if iM==1
        %x1=dx/2:dx:nx_c*dx-dx/2;
        %y1=dy/2:dy:ny_c*dy-dy/2;
        x1=[0:1:(nx_c-1)].*dx;
        y1=[0:1:(ny_c-1)].*dy;
        [X Y]=meshgrid(x1,y1);
        h_x=X-x1(ceil(nx_c/2)+1);
        h_y=Y-y1(ceil(ny_c/2)+1);
        
        C=precal_cov([0 0],[h_x(:) h_y(:)],Va);
        %keyboard
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

%% COMPUTE FFT and PAD
if ~isfield(options,'fftC');
    [nc1,nc2]=size(options.C);
    options.nf=2.^(ceil(log([nc1 nc2])/log(2)));
    % manally pad covariance model to avoid numerical artefacts
    npad_y=options.nf(1)-ny_c;
    npad_x=options.nf(2)-nx_c;
    C_pad=padarray(options.C,[0 ceil(npad_x/2)],'replicate','pre');
    C_pad=padarray(C_pad,[0 floor(npad_x/2)],'replicate','post');
    C_pad=padarray(C_pad,[ceil(npad_y/2) 0],'replicate','pre');
    C_pad=padarray(C_pad,[floor(npad_y/2) 0],'replicate','post');
    options.C=C_pad;
    options.fftC=fft2(fftshift(options.C),options.nf(1),options.nf(2));
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
           
    if options.resim_type==1;
        % BOX TYPE RESIMULATION 
        x0=dx.*(nx-nx_c)/2;
        y0=dy.*(ny-ny_c)/2;
        x0=0;y0=0;
        options.wrap_around=1;
        
        if isfield(options,'pos');
            % NEXT LINE MAY BE PROBLEMATIC USING NEIGHBORHOODS
            [options.used]=set_resim_data(x,y,z_rand,options.lim,options.pos+[x0 y0],options.wrap_around);
        else
            % CHOOSE CENTER OF BOX AUTOMATICALLY
            
            % wx, wy, allow selecting from the center also in a area just
            % outside the simulation area, the border zone. This is done to ensure that
            % nodes at the edge of the simulation error are allowe to vary.
            
            
            x0=ceil((rand(1)*(nx+options.wx)))-ceil(options.wx/2);
            y0=ceil((rand(1)*(ny+options.wy)))-ceil(options.wy/2);
            
            if x0<1; x0=size(z_rand,2)+x0;end
            if y0<1; y0=size(z_rand,1)+y0;end
            if x0>size(z_rand,2); x0=x0-size(z_rand,2);end
            if y0>size(z_rand,1); y0=y0-size(z_rand,1);end
            
            x0=dx*x0; 
            y0=dy*y0;
          
            options.pos=[x0 y0];
            [options.used]=set_resim_data([1:size(z_rand,2)]*dx,[1:size(z_rand,1)]*dy,z_rand,options.lim,options.pos,options.wrap_around);
            
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
        
        % find random sample of size 'n_resim'
        %N_all=prod(size(z_rand));
        %ii=randomsample(N_all,n_resim);
        %z_rand_new=randn(size(z_rand(ii)));
        %z_rand(ii) = z_rand_new;
        
        N_all=(nx)*(ny);
        % ADD PADDING !!!!
        N_all=(nx+options.wx)*(ny+options.wy);
        
        n_resim = min([n_resim N_all]);
        
        ii=randomsample(N_all,n_resim);
        
       
        z_rand_new=randn(size(z_rand(ii)));
        [ix,iy]=ind2sub([ny+options.wy,nx+options.wx],ii);
        for k=1:length(ii);
            
            x0=ix(k)-ceil(options.wx/2);
            y0=iy(k)-ceil(options.wx/2);
            
            if x0<1; x0=size(z_rand,2)+x0;end
            if y0<1; y0=size(z_rand,1)+y0;end
            if x0>size(z_rand,2); x0=x0-size(z_rand,2);end
            if y0>size(z_rand,1); y0=y0-size(z_rand,1);end
            
            z_rand(y0,x0)=z_rand_new(k);
        end
    end
end
    
z=z_rand;

options.prod=sqrt((options.fftC)).*fft2(z,options.nf(1),options.nf(2));
out=(ifft2(options.prod));
%out=real(ifft2(sqrt(options.fftC).*fft2(z,options.nf(1),options.nf(2))));

% prior likelihood
logL = -.5*sum(z(:).^2);

options.out=out;
out=out(1:ny,1:nx)+options.gmean;

if org.nx==1; out=out(:,1); end
if org.ny==1; out=out(1,:); end

options.nx=nx;
options.ny=ny;
options.nx_c=nx_c;
options.ny_c=ny_c;

