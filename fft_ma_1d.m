% fft_ma_1d :
% Call :
%    [out,z]=fft_ma_d(x,Va,options)
%
%    x: array, ex : x=1:1:80:
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
%  x=[1:1:50];
%  Va='1  Sph(10,.25,30)';
%  [out,z]=fft_ma_1d(x,Va);
%  plot(x,out);colorbar
%
%
%  x=[1:1:50];
%  Va='1  Sph(10,.25,30)';
%  [out1,z_rand]=fft_ma_1d(x,Va);
%  ii=300:350;
%  z_rand(ii)=randn(size(z_rand(ii)));
%  options.z_rand=z_rand;
%  [out2,z_rand2]=fft_ma_1(x,Va,options);
%  subplot(1,3,1),plot(x,[out1]);
%  subplot(1,3,2),plot(x,[out2]);
%  subplot(1,3,3),plot(x,[out2-out1]);
%
% original (FFT_MA_2D) Knud S. Cordua (June 2009)
% Thomas M. Hansen (September, 2009)
%


%
function [out,z_rand,options]=fft_ma_1d(x,Va,options);


options.null='';
if ~isstruct(Va);Va=deformat_variogram(Va);end
if ~isfield(options,'gmean');options.gmean=0;end
if ~isfield(options,'gvar');options.gvar=sum([Va.par1]);end
if ~isfield(options,'fac_x');options.fac_x=2;end

org.nx=length(x);

nx=length(x);
dx=x(2)-x(1); cell=dx; 

nx_c=nx*options.fac_x;

% COVARIANCE MODEL
if (~isfield(options,'C'))&(~isfield(options,'fftC'));
    options.C=zeros(1,nx_c);
    
    for iv=1:length(Va);
        
        % GET HMAX AND HMIN FROM SEMIVARIOGRAM MODEL
        % ONLY WORKS FOR ONE SEMIVRAIOHGRAM MODEL !!
        par2=Va(iv).par2;
        h_max=par2(1);
        if length(par2)>1
            h_min=h_max*par2(2);
            ang=par2(3);
        else
            h_min=h_max;
            ang=0;
        end
        try
            aniso=Va(iv).par2(2);
        catch
            aniso=1;
        end
        ang1=ang*(pi/180);
        
        
        x=dx/2:dx:nx_c*dx-dx/2;
        h_x=x-x(ceil(nx_c/2));
        
        % Transform into rotated coordinates:
        h_min=h_x*cos(ang1);
        h_max=h_x*sin(ang1);
        
        % Rescale the ellipse:
        h_min_rs=h_min;
        h_max_rs=aniso*h_max;
        dist=sqrt(h_min_rs.^2+h_max_rs.^2);
        
        % calc semivariogram
        Va2=Va(iv);
        try
            Va2.par2=Va(iv).par2(1)*Va(iv).par2(2);
        end
        options.C=options.C+semivar_synth(Va2,dist);        
    end
    options.C=options.gvar-options.C;
end


if ~isfield(options,'fftC');
    options.fftC=fft2(options.C);
end

% normal devaites
if isfield(options,'z_rand')
    z_rand=options.z_rand;
else
    z_rand=randn(1,nx_c);    
end

if isfield(options,'lim');
    % Sequential Gibbs Resimulation
    x0=dx.*(nx-nx_c)/2;
    x0=0;y0=0;
    options.wrap_around=1;
    if isfield(options,'pos');
        [options.used]=set_resim_data(x,0,z_rand,options.lim,options.pos+[x0 y0],options.wrap_around);
    else
        x0=dx*ceil(rand(1)*nx_c);
        options.pos=[x0 0];
        [options.used]=set_resim_data(1:nx_c,1,z_rand,options.lim,options.pos,options.wrap_around);
        
    end
    ii=find(options.used==0);
    z_rand_new=randn(size(z_rand(ii)));
    z_rand(ii) = z_rand_new;
end


z=z_rand;
options.out1=reshape(real(ifft2(sqrt(options.fftC).*fft2(z))),1,nx_c);

out=options.out1(1,1:nx)+options.gmean;

return

