% visim_set_broadband_covariance
%     Define a broadband (multiscale) covariance function, as
%     a sum of a number of single svale covariances
%     following:
%     Serban, A. Z., and Jacobsen, B. H. 2001. 
%     The use of broad-badn prior covariance for inverse paleoclimate estimation. 
%     Geophys. j. Int. 147, 29-40. 
%
% Call :
%    [sill,range,var0,V]=visim_set_broadband_covariance(V,Lmax,h,C,n_exp,var0)
%
% Run without arguments for an example
%
% See also visim_set_multiscale_covariance
%
function [sill,range,var0,V]=visim_set_broadband_covariance(V,Lmax,h,C,n_exp,var0)

if nargin==0
    
    Lmax=1e+5;
    h=0.9;
    C=0.1;
    n_exp=5;
    [sill,range,v0,V]=visim_set_broadband_covariance([],Lmax,h,C,n_exp);

    for xsiz=[1 10 100 1000];
        V.nx=200;
        V.xsiz=xsiz;V.ysiz=V.xsiz;
        [sill,range,v0,V]=visim_set_broadband_covariance(V,Lmax,h,C,n_exp);
        V=visim(V);
        figure;
        visim_plot_sim(V,1,[9 11],8,1,2);
        subplot(2,1,2);
        [sv,d]=semivar_synth(deformat_variogram(visim_format_variogram(V)),logspace(-4,12,200));
        semilogx(d,sv)
        watermark(visim_format_variogram(V,0),6,[0.01 0.91 .1 .1])
        suptitle(sprintf('dx=%6.3f',xsiz))
    end
end

if nargin<2,Lmax=1e+5;end
if nargin<3,h=0.5;end
if nargin<4,C=0.1;end
if nargin<5,n_exp=5;end
if nargin<6,var0=1;end

for j=0:n_exp;
    sill(j+1)=(C.^j).^h;
    range(j+1)=(C.^j)*Lmax*0.65;
end
sill=(sill./sum(sill)).*var0;


if nargout>3,
    if isempty(V)
        V=visim_init;
    end
    type=2;
    V=visim_set_multiscale_covariance(V,range,sill,type);
end