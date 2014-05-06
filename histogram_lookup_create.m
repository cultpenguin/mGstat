function hl=histogram_lookup_create(d,d_min,d_max,w1,w2);
% histogram_lookup_create : Implements histogram lookup table for Direct
% simulation based on Deutsch et al. (2000) and Oz et al. (2003)
%
% Call : 
%   histogram_lookup_create(d_target,d_min,d_max,w1,w2); 
% 
% See also: histogram_lookup_simulate, nscore
% 
if nargin<2, d_min=min(d); end
if nargin<3, d_max=max(d); end
if nargin<4, w1=2; end
if nargin<5, w2=2; end

[d_nscore,o_nscore]=nscore(d,2,2,d_min,d_max);

%%
nm=100;
nv=100;
n_mc=10000;
Nq=170;

ns_mean_arr=linspace(-3.5,3.5,nm);
ns_var_arr=linspace(0,2,nv);

d_var=zeros(nm,nv);
d_mean=zeros(nm,nv);
d_cdf=zeros(nm,nv,n_mc);

d_cdf2=zeros(nm,nv,Nq);

for iv=1:length(ns_var_arr)
for im=1:length(ns_mean_arr)
    ns_mean=ns_mean_arr(im);
    ns_var=ns_var_arr(iv);
    
    %  %doMonte
    ns_reals=randn(1,n_mc)*sqrt(ns_var)+ns_mean;
    
    d_back=inscore(ns_reals,o_nscore);
    
    
  
    d_mean(im,iv)=mean(d_back);
    d_var(im,iv)=var(d_back);
    
    id=[1:n_mc]';
    pk=id./n_mc-.5/n_mc;
    d_pk=pk;
    d_cdf(im,iv,:)=sort(d_back);
    %d_cdf
    
    %% BACK TRANS OF QUANTILES
    d_pk2=(1:Nq)./Nq-.5./Nq;
    d_cdf2(im,iv,:)=inscore(norminv(d_pk2,ns_mean,sqrt(ns_var)),o_nscore);
    
    
    %%
    %hist(d_back,[0:.1:10]);drawnow;pause(.1);
    doPlot=0;
    if doPlot==1;
        plot(squeeze(d_cdf(im,iv,:)),d_pk,'k-',squeeze(d_cdf2(im,iv,:)),d_pk2,'r*');
        set(gca,'xlim',[2.5 5.5])
        drawnow;%pause(.1);
    end
    
end
end

hl.pk=d_pk2;
hl.cdf=d_cdf2;

hl.ns_mean_arr=ns_mean_arr;
hl.ns_var_arr=ns_var_arr;
hl.d_mean=d_mean;
hl.d_var=d_var;
hl.d_min=d_min;
hl.d_max=d_max;
hl.d_mean_all=mean(d);
hl.d_var_all=var(d);
hl.d_target=d;
hl.o_nscore=o_nscore;


