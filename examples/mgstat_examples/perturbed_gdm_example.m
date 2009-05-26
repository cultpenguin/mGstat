% perutrbed_gdm_example : Comnbination of perturbed simualtion and GDM
%
% See also snesim_set_resim_data, grad_deform
%

%doResim=1;doGradDef=1;gdm_step=0.6;perturb_width=10;
doResim=0;doGradDef=1;gdm_step=0.6;perturb_width=10;

txt=sprintf('RSIM%d_RSIMWIDTH_%g_GDM%d_GDMSTEP_%g',doResim,perturb_width,doGradDef,gdm_step);

V=visim_init([.5:2:40],[.5:2:40]);
V.debuglevel=-2;
V=visim(V);
D=V.D;
maxit=100;
nsaves=10;
ij=round(linspace(1,maxit,nsaves));

Dsim=zeros(size(V.D,1),size(V.D,2),nsaves);
j=0;
for i=1:maxit;
    progress_txt(i,maxit,'simulation')
    V.rseed=V.rseed+1;
   
    if doResim==1
        V.cond_sim=2;
        V=visim(snesim_set_resim_data(V,D',perturb_width.*[1 1]));
    else
        V.cond_sim=0;
        V=visim(V);
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
    imagesc(D);
    caxis([8 12]);
    axis image;
    colorbar;
    drawnow;
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

[g_uncon,hc_uncon]=visim_plot_semivar_real(V,[45 135],[10 10],[20 20],[1 1]);
[g_pert,hc_pert]=visim_plot_semivar_real(Vpert,[45 135],[10 10],[20 20],[1 1]);

close all;
figure(1);set_paper;
subplot(1,2,1);hist([mean_pert;mean_uncon]');legend('Perturbed','Uncon')
subplot(1,2,2);plot([mean_pert;mean_uncon]');legend('Perturbed','Uncon')
print_mul(sprintf('%s_mean',txt))

figure(2);;set_paper;
subplot(1,2,1);hist([var_pert;var_uncon]');legend('Perturbed','Uncon')
subplot(1,2,2);plot([var_pert;var_uncon]');legend('Perturbed','Uncon')
print_mul(sprintf('%s_var',txt))

figure(3);;set_paper;
for i=1:2;
subplot(1,2,i);
plot(hc_pert{i},g_pert{i},'k-',hc_uncon{i},g_uncon{i},'r-');
end
print_mul(sprintf('%s_semivar',txt))

figure(4);set_paper;
visim_plot_sim(Vpert,V.nsim,[8 12],10,ceil(sqrt(nsaves)))
suptitle(['PERTURBED ',txt])
print_mul(sprintf('%s_reals_pert',txt))

figure(5);set_paper;
visim_plot_sim(V,V.nsim,[8 12],10,ceil(sqrt(nsaves)))
suptitle(['UNCONDITIONAL ',txt])
print_mul(sprintf('%s_reals_uncon',txt))



