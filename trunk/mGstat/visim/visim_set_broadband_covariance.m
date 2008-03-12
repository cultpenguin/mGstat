% visim_set_broadband_covariance
%     Define a broadband (multiscale) covariance function, as
%     a sum of a number of single svale covariances.
%
% Call :
%    V=visim_set_broadband_covariance(V,range,cc,type)
%    range  : array of single scale covariance ranges
%    cc     : array of single scale covariance sills OR
%             value of multiscale sill level
%    type   : Covariance type.
%
%
% Run argument for an example
%
function V=visim_set_broadband_covariance(V,range,cc,type)

if nargin==0
    V=visim_init;
%    V=visim_init;
%    visim_set_broadband_covariance(V);
%    V=visim(V);
    
for n=1:40;
    V=visim_set_broadband_covariance(V,logspace(log10(4),log10(100),n),.2,3);
    VA=deformat_variogram(visim_format_variogram(V));
    [sv,d]=semivar_synth(VA,linspace(0,100,100));
    plot(d,sv);axis([0 100 0 .2])
    drawnow;
    pause(1);
end
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
end