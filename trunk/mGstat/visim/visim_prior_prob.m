% visim_prior_prob : Likelihood that samples form posteriori are samples from prior
%
% Call : 
%   [Lmean,L,Vc,Vu]=visim_prior_prob(V,nsim);
%
function [Lmean,L,Vc,Vu]=visim_prior_prob(V,nsim);

[p,f,e]=fileparts(V.parfile);

if nargin==1;
  nsim=V.nsim;
end

% CONDITIONAL SIMULATION
Vc=V;
%if isfield(Vc,'D')==0
  Vc=visim(Vc);
%end

% UNCONDITIONAL SIMULATION
Vu=V;
Vu.parfile=sprintf('%s_unc.par',f);
Vu.cond_sim=0;
Vu.nsim=nsim;
Vu=visim(Vu);

figure(1);clf;
[Vu.VaExp.g,Vu.VaExp.hc,sv,Vu.VaExp.hc2]=visim_plot_semivar_real(Vu,[0 90],15,8,.5);
figure(2);clf;
%if isfield(Vc,'VaExp')==0
  [Vc.VaExp.g,Vc.VaExp.hc,sv,Vc.VaExp.hc2]=visim_plot_semivar_real(Vc,[0 90],15,8,.5);
%end



iuse_1=find(~isnan(sum(Vu.VaExp.g{1}')));
iuse_2=find(~isnan(sum(Vu.VaExp.g{2}')));
%iuse=1:1:12;
g1=Vu.VaExp.g{1}(iuse_1,:);
g2=Vu.VaExp.g{2}(iuse_2,:);
gcc_cross=cov([g1',g2']);

g0_1=mean(Vu.VaExp.g{1}');
g0_2=mean(Vu.VaExp.g{2}');
g0=[g0_1(iuse_1),g0_2(iuse_2)];


for is=1:Vc.nsim,
  %g_est=Vu.VaExp.g{i}(:,is)'; % UNCOND
  g_est1=Vc.VaExp.g{1}(:,is)'; % COND
  g_est2=Vc.VaExp.g{2}(:,is)'; % COND
  g_est=[g_est1(iuse_1),g_est2(iuse_2)];
  
  dg=g0-g_est;

  L(is)=-.5*dg*inv(gcc_cross)*dg';

end
Lmean=mean(L);



