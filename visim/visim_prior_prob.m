% visim_prior_prob : Likelihood that samples form posteriori are samples from prior
%
% Call : 
%   [Lmean,Vu,Vc,out]=visim_prior_prob(V,options);
%

function [Lmean,Vu,Vc,out]=visim_prior_prob(V,options);
    
    Lmean=[];L=[];Ldim=[];
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
    
   maxdist=  sqrt((max(V.x)-min(V.x)).^2+(max(V.y)-min(V.y)).^2+(max(V.z)-min(V.z)).^2);
  cutoff=[1 1]*.3*maxdist;
  mgstat_verbose([mfilename,' : Cutoff=',num2str(cutoff)],0);
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
        %figure(1);clf;
        [Vu.VaExp.g,Vu.VaExp.hc,sv,Vu.VaExp.hc2]=visim_plot_semivar_real(Vu,[0],tolerance(1),cutoff(1),width(1));
    end
    if isfield(Vc,'VaExp')==0;
        %figure(2);clf;
        [Vc.VaExp.g,Vc.VaExp.hc,sv,Vc.VaExp.hc2]=visim_plot_semivar_real(Vc,[0],tolerance(1),cutoff(1),width(1));
    end
else
    % ANISOTROPIC    
    if isfield(Vu,'VaExp')==0;
        %figure(1);clf;
        [Vu.VaExp.g,Vu.VaExp.hc,sv,Vu.VaExp.hc2]=visim_plot_semivar_real(Vu,[0 90],tolerance,cutoff,width);
    end
    if isfield(Vc,'VaExp')==0;
        %figure(2);clf;
        [Vc.VaExp.g,Vc.VaExp.hc,sv,Vc.VaExp.hc2]=visim_plot_semivar_real(Vc,[0 90],tolerance,cutoff,width);
    end
end

%out.Vc=Vc;
%out.Vu=Vu;

% MEAN SEMIVARIOGRAMS
for i=1:length(Vc.VaExp.g)
    out.semi_mean_u{i}=mean(Vu.VaExp.g{i}');
    out.semi_mean_c{i}=mean(Vc.VaExp.g{i}');
end
ds_sum=0;
for l=1:length(out.semi_mean_u)
    
    ds=out.semi_mean_u{l}-out.semi_mean_c{l};
    ds=sqrt(sum(abs(ds(find(~isnan(ds))))));
    ds=ds(:).^ 2;
    ds=sqrt(sum(ds(find(~isnan(ds)))));
    ds_sum=ds_sum+ds;
    
    out.semi_mean_dir(l)=ds;
end
out.semi_mean=ds_sum;

out.options=options;
% CHOOSE HERE TO CALL COVAR PROB


%% COVAR PRIOR PROB FOR ALL DIRECTIONS
for ic=1:length(Vc.VaExp.g)
    VaExp_U.g{1}=Vu.VaExp.g{ic};
    VaExp_U.hc{1}=Vu.VaExp.hc{ic};
    VaExp_U.hc2{1}=Vu.VaExp.hc2{ic};
    
    VaExp_C.g{1}=Vc.VaExp.g{ic};
    VaExp_C.hc{1}=Vc.VaExp.hc{ic};
    VaExp_C.hc2{1}=Vc.VaExp.hc2{ic};
    
    [Lmean_h{ic}]=covar_prob(VaExp_U,VaExp_C,options);
        
end
out.Lmean_h=Lmean_h;

%COVAR PROB FOR BOTH DIRS

[Lmean,L,Ldim]=covar_prob(Vu.VaExp,Vc.VaExp,options);
[Lmean_u,L_u,Ldim_u]=covar_prob(Vu.VaExp,Vu.VaExp,options);

if (options.use_mean)==1
    % COMBINE THE LIKELIHOOD OF THE MEAN AND THE COVARIANCE
    Lcombine=L+Lm;
    Lmean=log(mean(exp(Lcombine)));
end

out.Lmean=Lmean;
out.Lmean_u=Lmean_u;
out.L_u=L_u;
out.L=L;
out.L_rel=Lmean-Lmean_u;


