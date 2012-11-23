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
% %%
%  x=[1:1:200];
%  Va='1 Sph(40)';
%  [out,z_rand,options]=fft_ma_1d(x,Va);
%  plot(x,out,'r-');
%  hold on;p_c=plot(x,out,'k-');hold off
%  axis([min(x) max(x) -4 4])
%  options.lim=2;
%  for i=1:500;
%     options.z_rand=z_rand;
%    [out,z_rand,options]=fft_ma_1d(x,Va,options);
%    set(p_c,'Ydata',out);drawnow;pause(.01)
%  end
%
%
% original (FFT_MA_2D) Knud S. Cordua (June 2009)
% Thomas M. Hansen (September, 2009)
%


%
function [out,z_rand,options,logL]=fft_ma_1d(x,Va,options);


options.null='';
if ~isstruct(Va);Va=deformat_variogram(Va);end
if ~isfield(options,'gmean');options.gmean=0;end
if ~isfield(options,'gvar');options.gvar=sum([Va.par1]);end
if ~isfield(options,'fac_x');options.fac_x=2;end

org.nx=length(x);

nx=length(x);
dx=x(2)-x(1); cell=dx;

nx_c=nx*options.fac_x;



%% REMOVE OLD COVARIANCE OF options.constant_C=0
if (isfield(options,'constant_C'));
    if options.constant_C==0;
        try;options=rmfield(options,'C');end
        try;options=rmfield(options,'fftC');end
    end
end

%% COVARIANCE MODEL
if (~isfield(options,'C'))&(~isfield(options,'fftC'));
    options.C=zeros(1,nx_c);
        
    
    h_x=[0:1:(nx_c-1)].*dx;
    x=dx/2:dx:nx_c*dx-dx/2;h_x=x-x(ceil(nx_c/2));
    %h_x=x;
    options.C=precal_cov([0],[h_x(:)],Va);
    
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


%% RESIM
if ~isfield(options,'resim_type');
    options.resim_type=2;
end
if isfield(options,'lim');
    if options.resim_type==1;
        % Sequential Gibbs Resimulation
        x0=dx.*(nx-nx_c)/2;
        x0=0;y0=0;
        options.wrap_around=1;
        if isfield(options,'pos');
            [options.used]=set_resim_data(x,0,z_rand,options.lim,options.pos+[x0 y0],options.wrap_around);
        else
            x0=dx*ceil(rand(1)*nx_c);
            options.pos=[x0 0];
            [options.used]=set_resim_data([1:nx_c]*dx,0,z_rand,options.lim,options.pos,options.wrap_around);
            
        end
        ii=find(options.used==0);
        %if isempty(ii); keyboard;end
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

out=reshape(real(ifft2(sqrt(options.fftC).*fft2(z_rand))),1,nx_c);

out=out(1,1:nx)+options.gmean;

logL = -.5*sum(z_rand(:).^2);

return

