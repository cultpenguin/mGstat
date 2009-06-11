% perutrbed_gdm_example : Comnbination of perturbed simualtion and GDM
%
% See also visim_set_resim_data, grad_deform
%
if ~exist('doPlot'), doPlot=0;end

if ~exist('doResim'), doResim=1;end
if ~exist('perturb_width'), perturb_width=5;end
if ~exist('perturb_unc'), perturb_unc=10;end
if ~exist('doGradDef'), doGradDef=0;end
if ~exist('gdm_step'), gdm_step=0.6;end
if ~exist('maxit');maxit=10000;end
if ~exist('nsaves');nsaves=300;end
if ~exist('dx','var');dx=2;end
if ~exist('it','var');it=2;end

if nsaves>maxit
    nsaves=maxit;
end

%doResim=1;doGradDef=1;gdm_step=0.6;perturb_width=10;
%doResim=0;perturb_width=5;doGradDef=1;gdm_step=0.6;
%doResim=1;perturb_width=5;doGradDef=0;gdm_step=0.6;
V=visim_init([.5:dx:40],[.5:dx:40]);

V.debuglevel=-2;
V.Va.it=it;
V=visim(V);
D=V.D;
ij=round(linspace(1,maxit,nsaves));

txt=sprintf('RSIM%d_RSIMWIDTH_%g_GDM%d_GDMSTEP_%g_dx%g',doResim,perturb_width,doGradDef,gdm_step,dx);
disp(txt)

Dsim=zeros(size(V.D,1),size(V.D,2),nsaves);
Dmean=zeros(1,maxit).*NaN;;
Dvar=zeros(1,maxit).*NaN;

j=0;
for i=1:maxit;
    %progress_txt(i,maxit,txt)
    V.rseed=V.rseed+1;
    Vold=V;
    if doResim==1
        if perturb_unc>0
            V.cond_sim=1;
        else
            V.cond_sim=2;
        end
        V=visim(visim_set_resim_data(V,D',perturb_width.*[1 1],[],perturb_unc));
    else
        V.cond_sim=0;
        V=visim(V);
    end
    
    if ~isfield(V,'D')
        V=Vold;
    end
    
    if doGradDef==1;
        D=grad_deform(D-V.gmean,  V.D-V.gmean,gdm_step)+V.gmean;
    else
        D=V.D;
    end
    
    if ~isempty(find(ij==i));
        j=j+1;
        Dsim(:,:,j)=D;
    end
    Dmean(i)=mean(D(:));
    Dvar(i)=var(D(:));
       
    if doPlot==1;
        subplot(2,1,1);
        imagesc(D);
        caxis([8 12]);
        axis image;
        colorbar;
        drawnow;
        subplot(2,2,3);
        plot(1:maxit,Dmean,'k-');ylabel('mean');
        subplot(2,2,4);
        plot(1:maxit,Dvar,'k-');ylabel('variance');
    end
end

% Compare with unconditional simulation
V.cond_sim=0;
V.nsim=nsaves;
V=visim(V);

for j=1:nsaves
    d_pert=Dsim(:,:,j);
    d_uncon=V.D(:,:,j);
    mean_pert(j)=mean(d_pert(:));
    mean_uncon(j)=mean(d_uncon(:));
    var_pert(j)=var(d_pert(:));
    var_uncon(j)=var(d_uncon(:));
end
Vpert=V;
Vpert.D=Dsim;

%figure(2);
%for i=1:Vpert.nsim;imagesc(V.x,V.y,Vpert.D(:,:,i));axis image;caxis([8 12]);drawnow;end
%return;

figure(2);set_paper;;clf;
subplot(2,2,1);hist([mean_pert;mean_uncon]');legend('Perturbed','Uncon');xlabel('mean')
subplot(2,2,2);
p=plot(ij,[mean_pert;mean_uncon]','linewidth',2);legend('Perturbed','Uncon');ylabel('mean')
hold on
plot(1:1:maxit,[Dmean],'.','color',1-((1-get(p(1),'color'))*0.5),'linewidth',.1,'MarkerSize',.1);
hold off
subplot(2,2,3);hist([var_pert;var_uncon]');legend('Perturbed','Uncon');xlabel('var')
subplot(2,2,4);
p=plot(ij,[var_pert;var_uncon]','linewidth',2);legend('Perturbed','Uncon');ylabel('var')
hold on
plot(1:1:maxit,[Dvar],'.','color',1-((1-get(p(1),'color'))*0.5),'linewidth',.1,'MarkerSize',.1);
hold off
s=suptitle(['PERTURBED ',txt]);set(s,'interpreter','none')
print_mul(sprintf('%s_mean_var',txt))

if nsaves<30,
    isimplot=1:1:nsaves;
else
    isimplot=round(linspace(1,nsaves,30));
end

cax=[8 12];FS=6;
figure(4);set_paper;;clf;
visim_plot_sim(Vpert,isimplot,cax,FS);
s=suptitle(['PERTURBED ',txt]);set(s,'interpreter','none')
print_mul(sprintf('%s_reals_pert',txt))

figure(5);set_paper;
visim_plot_sim(V,isimplot,cax,FS);
s=suptitle(['UNCONDITIONAL ',txt]);set(s,'interpreter','none')
print_mul(sprintf('%s_reals_uncon',txt))

return


[g_uncon,hc_uncon]=visim_plot_semivar_real(V,[45 135],[10 10],[20 20],[1 1].*dx,0);
[g_pert,hc_pert]=visim_plot_semivar_real(Vpert,[45 135],[10 10],[20 20],[1 1].*dx,0);
figure(3);;set_paper;;clf;
for i=1:2;
subplot(1,2,i);
plot(hc_pert{i},g_pert{i},'k-',hc_uncon{i},g_uncon{i},'r-');
end
s=suptitle(['PERTURBED ',txt]);set(s,'interpreter','none')
print_mul(sprintf('%s_semivar',txt))

save([txt,'.mat']);

