% visim_prior_prob : Likelihood that samples form posteriori are samples from prior
%
% Call : 
%   [Lmean,L,Vc,Vu]=visim_prior_prob(V,nsim);
%
function [Lmean,L,Vc,Vu]=visim_prior_prob(V,nsim,NoCrossC);

[p,f,e]=fileparts(V.parfile);

if nargin==1;
  nsim=V.nsim;
end

if nargin<3
    NoCrossC=0;
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
%iuse_1=iuse;
%iuse_2=iuse;

g1=Vu.VaExp.g{1}(iuse_1,:);
g2=Vu.VaExp.g{2}(iuse_2,:);
gcc_1=cov([g1']);
gcc_2=cov([g2']);
gcc_cross=cov([g1',g2']);

%
%NoCrossC=1;
if NoCrossC==1
    gcc_cross2=0.*gcc_cross;
    for i=1:size(gcc_cross,1);
        gcc_cross2(i,i)=gcc_cross(i,i);       
    end
    gcc_cross=gcc_cross2;  
end

g0_1=mean(Vu.VaExp.g{1}');
g0_2=mean(Vu.VaExp.g{2}');
g0=[g0_1(iuse_1),g0_2(iuse_2)];

g0_1=g0_1(iuse_1);
g0_2=g0_2(iuse_2);

L=zeros(1,Vc.nsim);

for is=1:Vc.nsim,
  g_est1=Vc.VaExp.g{1}(:,is)'; % COND
  g_est2=Vc.VaExp.g{2}(:,is)'; % COND

  % g_est1=Vu.VaExp.g{1}(:,is)'; % COND
  % g_est2=Vu.VaExp.g{2}(:,is)'; % COND

  
  % JOINT PROBABILITY
  g_est=[g_est1(iuse_1),g_est2(iuse_2)];
  dg=g0-g_est;
  L(is)=-.5*dg*inv(gcc_cross)*dg';
  
  % EACH DIRECTION INDEPENEDANTLY
  dg1=g0_1-g_est1(iuse_1);
  dg2=g0_2-g_est2(iuse_2);
  L1(is)=-.5*dg1*inv(gcc_1)*dg1';
  L2(is)=-.5*dg2*inv(gcc_2)*dg2';

end
%Lmean=log(mean(exp(L)));
Lmean=mean(L);


doPlot=0;
if doPlot==1;
  ii=1;subplot(2,2,ii);
  plot(Vu.VaExp.hc{ii},Vu.VaExp.g{ii},'-','color',[1 1 1].*.8)
  hold on;
  plot(Vc.VaExp.hc{ii},Vc.VaExp.g{ii},'k-');
  plot(Vc.VaExp.hc{ii}(iuse_1),g0_1,'r-','LineWidth',2);
  std0_1=sqrt(diag(gcc_1))';
  plot(Vc.VaExp.hc{ii}(iuse_1),g0_1+std0_1,'r-','LineWidth',1);
  plot(Vc.VaExp.hc{ii}(iuse_1),g0_1-std0_1,'r-','LineWidth',1);  
  hold off

  ii=2;subplot(2,2,ii);
  plot(Vu.VaExp.hc{ii},Vu.VaExp.g{ii},'-','color',[1 1 1].*.8)
  hold on;
  plot(Vc.VaExp.hc{ii},Vc.VaExp.g{ii},'k-');
  plot(Vc.VaExp.hc{ii}(iuse_2),g0_2,'r-','LineWidth',2);
  std0_2=sqrt(diag(gcc_2))';
  plot(Vc.VaExp.hc{ii}(iuse_2),g0_2+std0_2,'r-','LineWidth',1);
  plot(Vc.VaExp.hc{ii}(iuse_2),g0_2-std0_2,'r-','LineWidth',1);  
  hold off
end



