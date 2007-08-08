% visim_prior_prob : Likelihood that samples form posteriori are samples from prior
%
% Call : 
%   [Lmean,Vu,Vc,out]=visim_prior_prob(V,options);
%

%   [Lmean,L,Ldim,Vc,Vu,mfP,mfPAll]=visim_prior_prob(V,options);
%function [Lmean,L,Ldim,Vc,Vu,mfP,mfPAll,Lmean_u,L_u,Ldim_u,out]=visim_prior_prob(V,options);
function [Lmean,Vu,Vc,out]=visim_prior_prob(V,options);
    
    Lmeam=[];L=[];Ldim=[];
    if (V.nsim==0)
        disp(sprintf('%s You have specified V.nsim=0. This is no good.',mfilename))
        return
    end
    mfP=NaN;    mfPAll=NaN;
[p,f,e]=fileparts(V.parfile);

if nargin<2
    options.null='';
end

if isfield(options,'nsim')==1, nsim=options.nsim; else nsim=V.nsim; end
if isfield(options,'nocross')==1, nocross=options.nocross; else nocross=0; end
nang=2;
if isfield(options,'tolerance')==1, 
  tolerance=options.tolerance; 
else 
  tolerance=[15 15]; 
end
if length(tolerance)~=nang,  tolerance=ones(1,nang).*tolerance;end

if isfield(options,'cutoff')==1, 
  cutoff=options.cutoff; 
else 
  cutoff=[8 8]; 
end
if length(cutoff)~=nang,  cutoff=ones(1,nang).*cutoff;end


if isfield(options,'width')==1, 
  width=options.width; 
else 
  width=cutoff/12;
end

if isfield(options,'use_mean')==0
    options.use_mean=0;
end
if isfield(options,'only_mean')==0
    options.only_mean=0;
end

if isfield(options,'pure_sill')==0
    options.pure_sill=0;
end

if isfield(options,'isotropic')==0	
    if (V.Va.a_hmin==V.Va.a_hmax)	
        options.isotropic=1;	
    else		
        options.isotropic=0;	
    end	
end


% CONDITIONAL SIMULATION
if isfield(options,'Vc')==1
    Vc=options.Vc;
else
    Vc=V;
    Vc=visim(Vc);
end

if isfield(options,'m_ref');
    for i=1:Vc.nsim;
         d=Vc.D(:,:,i);
         c=corrcoef(options.m_ref(:),d(:));
         mfPAll(i)=mean(abs(options.m_ref(:)-d(:)));
         % mfPAll(i)=c(2);        
    end
     mfP=mean(mfPAll);
    % 
end
out.mfP=mfP;
out.mfPAll=mfPAll;

% UNCONDITIONAL SIMULATION
if isfield(options,'Vu')==1
    Vu=options.Vu;
else
    Vu=V;
    Vu.parfile=sprintf('%s_unc.par',f);
    Vu.cond_sim=0;
    Vu.nsim=nsim;
    Vu=visim(Vu);
end

%% MEAN PROB START
%% MEAN PROB END
for i=1:Vu.nsim
    du=Vu.D(:,:,i);
    m_u(i)=mean(du(:));
    v_u(i)=var(du(:));
end
mean_mean=mean(m_u);
mean_var=var(m_u);
mean_var=mean(v_u);
var_var=var(v_u);
for i=1:Vc.nsim
    dc=Vc.D(:,:,i);
    m_c(i)=mean(dc(:));
    v_c(i)=var(dc(:));    
    Lm(i)=-.5*(m_c(i)-mean_mean).^2./mean_var;
    Lv(i)=-.5*(v_c(i)-mean_var).^2./var_var;
end

out.Lm=Lm;
out.Lv=Lv;
out.m_c=m_c;
out.v_c=v_c;
out.m_u=m_u;
out.v_u=v_u;

if (options.only_mean==1)
    L=Lm;
    Lmean=log(mean(exp(L)));
    %Lmean=mean(L);
    out.L=L;
    return
end


if (options.pure_sill==1)
    if (options.use_mean)==1
        L=Lv+Lm;
    else
        L=Lv;
    end
    Lmean=log(mean(exp(L)));
    %Lmean=mean(L);
    out.L=L;
    return
end



% CHECK OF ISOTROPY !!
if (options.isotropic==1)
%if ( (V.Va.a_hmin==V.Va.a_hmax) );% &  (V.Va.a_hmin==V.Va.a_vert) )
    % ISOTROPIC
    disp('ISOTROPIC')
    tolerance=180;
    if isfield(Vu,'VaExp')==0;
        figure(1);clf;
        [Vu.VaExp.g,Vu.VaExp.hc,sv,Vu.VaExp.hc2]=visim_plot_semivar_real(Vu,[0],tolerance(1),cutoff(1),width(1));
    end
    if isfield(Vc,'VaExp')==0;
        figure(2);clf;
        [Vc.VaExp.g,Vc.VaExp.hc,sv,Vc.VaExp.hc2]=visim_plot_semivar_real(Vc,[0],tolerance(1),cutoff(1),width(1));
    end
else
    % ANISOTROPIC    
    if isfield(Vu,'VaExp')==0;
        figure(1);clf;
        [Vu.VaExp.g,Vu.VaExp.hc,sv,Vu.VaExp.hc2]=visim_plot_semivar_real(Vu,[0 90],tolerance,cutoff,width);
    end
    if isfield(Vc,'VaExp')==0;
        figure(2);clf;
        [Vc.VaExp.g,Vc.VaExp.hc,sv,Vc.VaExp.hc2]=visim_plot_semivar_real(Vc,[0 90],tolerance,cutoff,width);
    end
end


% CHOOSE HERE TO CALL COVAR PROB
[Lmean,L,Ldim]=covar_prob(Vu.VaExp,Vc.VaExp,options);
[Lmean_u,L_u,Ldim_u]=covar_prob(Vu.VaExp,Vu.VaExp,options);
 
if (options.use_mean)==1
    % COMBINE THE LIKELIHOOD OF THE MEAN AND THE COVARIANCE
    Lcombine=L+Lm;
    Lmean=log(mean(exp(L+Lm)));
end

out.L=L;


return

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

if nocross==1
    gcc_cross2=0.*gcc_cross;
    for i=1:size(gcc_cross,1);
        gcc_cross2(i,i)=gcc_cross(i,i);       
    end
    gcc_cross=gcc_cross2;  
end
gcc_cross_diag=diag(gcc_cross);

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

%[Lmean2,L2,Ldim2]=covar_prob(Vu.VaExp,Vc.VaExp,options);


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


