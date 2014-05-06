function [z,d_cdf,pk,d_mean,d_var]=histogram_lookup_simulate(hl,d_mean,d_var);
% histogram_lookup_simulate
%
% Call: 
%  hl=histogram_lookup_create(d_target);
%  d_sim=histogram_lookup_simulate(hl,d_mean,d_var);
%
% See also: histogram_lookup_create
%

x=(hl.d_mean-d_mean)./sqrt(hl.d_var_all);
y=(hl.d_var-d_var)./sqrt(hl.d_var_all);
d=sqrt(x.^2+y.^2);
[im,iv]=find(d==min(d(:)))

d_mean=hl.d_mean(im,iv);
d_var=hl.d_var(im,iv);

pk=hl.pk;
d_cdf=squeeze(hl.cdf(im,iv,:));

r=rand(1);
r=0.20730305;
z=interp1(pk,d_cdf,r,'nearest');
