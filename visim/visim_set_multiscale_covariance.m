% visim_set_multiscale_covariance
%     Define a broadband (multiscale) covariance function, as
%     a sum of a number of single svale covariances.
%
% Call :
%    V=visim_set_multiscale_covariance(V,range,cc,type)
%    range  : array of single scale covariance ranges
%    cc     : array of single scale covariance sills OR
%             value of multiscale sill level
%    type   : Covariance type.
%
%
% 
%
function V=visim_set_multiscale_covariance(V,range,cc,type)

if nargin==0
    V=visim_init;
    V.Va.nugget=0.00001;        
    j=0;
    for n=3:1:3;
    maxrange=50000;
    for minrange=logspace(log10(1),log10(maxrange),10) 
        j=j+1;
        V=visim_set_broadband_covariance(V,logspace(log10(minrange),log10(maxrange),n),.2,2);
        VA=deformat_variogram(visim_format_variogram(V));
        [sv,d]=semivar_synth(VA,linspace(0,1000,10000));
        figure(1)
        plot(d,sv);axis([0 100 0 .2])
        if j==1; hold on; end
        V.nsim=6;
        V.nx=200;
        V=visim(V);
        figure(1+j);
        visim_plot_sim(V,V.nsim,[8 12],10,1,V.nsim);   
        eval(sprintf('print -dpdf frame%02d.pdf',j))
        drawnow;
    end
    end
    figure(1);hold off
    abcpdfmg('frame*.pdf','all_frames.pdf',1)
    return
end

if nargin<2
    range=logspace(-1,2,3);
end

if nargin<3
    cc=1;
end

if nargin<4
    type=V.Va.it(1);
end

V.Va.nst=length(range);

if length(cc)==1
    cc=ones(V.Va.nst,1).* (cc./V.Va.nst);
end
for i=1:V.Va.nst
    V.Va.it(i)=type;
    V.Va.cc(i)=cc(i);
    V.Va.ang1(i)=0;
    V.Va.ang2(i)=0;
    V.Va.ang3(i)=0;
    V.Va.a_hmax(i)=range(i); 
    V.Va.a_hmin(i)=range(i); 
    V.Va.a_vert(i)=range(i); 
    
    V.search_radius.hmax=2*max(range);
    V.search_radius.hmin=2*max(range);
    V.search_radius.hvert=2*max(range);
    
end

% Next two lines until VISIM is checked for how it uses V.gvar...
maxr=sqrt((V.nx*V.xsiz).^2+(V.ny*V.ysiz).^2);
V.gvar=semivar_synth(deformat_variogram(visim_format_variogram(V)),maxr);
%V.gvar=sum(V.Va.cc);