visim_clean;
V=visim_init(1:1:100,1:1:100,1);
V.rseed=1;ceil(100000*rand);
V.debuglevel=-2;

V.Va.it=3;


f_target='reference.eas';

d_target=[-4, -4, -4, 0, 4, 4]';
%d_target=[randn(1,100).*.1-4 randn(1,100).*.1+4]';
write_eas(f_target,d_target);



V.ccdf=1;
V.refhist.do_discrete=1;
V.refhist.fname=f_target;
V.tail.zmin=min(d_target);
V.tail.zmax=max(d_target);

V.refhist.n_Gmean=110;
V.refhist.n_Gvar=100;
V.gmean=mean(d_target);
V.gvar=var(d_target);
V.Va.cc=V.gvar;

V.nsimdata=118;
V2=visim(V);
V.nsimdata=28;
V=visim(V);

figure(1);clf;
subplot(1,2,1);
imagesc(V.x,V.y,V.D);colorbar
axis image;
subplot(1,2,2);
hist(V.D(:))

figure(3);clf;
imagesc([V.D,V2.D,V.D-V2.D]);
axis image
return
%%
c_var=load('cond_var_visim.out');
c_mean=load('cond_mean_visim.out');
c_cpdf=load('cond_cpdf_visim.out');
c_imean=load('cond_imean_visim.out');
%%
figure(2);clf
igm=V.refhist.n_Gmean;igv=V.refhist.n_Gvar;
gm=linspace(V.refhist.min_Gmean,V.refhist.max_Gmean,V.refhist.n_Gmean);
gv=linspace(V.refhist.min_Gvar,V.refhist.max_Gvar,V.refhist.n_Gvar);
 

ii=find((c_mean<0.2)&(c_mean>-.2)&(c_var<10.5)&(c_var>9.5));c_mean(ii);
[ix,iy]=ind2sub([length(gv) length(gm)],ii);

subplot(2,1,1);
imagesc(gm,gv,reshape(c_mean,igv,igm));colorbar;title('cmean');xlabel('Gmean');ylabel('Gvar')
set(gca,'ydir','normal')
hold on
plot(gm(ix),gv(iy),'k.');
hold off

subplot(2,1,2);
imagesc(gm,gv,reshape(c_var,igv,igm));colorbar;title('cvar');xlabel('Gmean');ylabel('Gvar')
set(gca,'ydir','normal')
hold on
plot(gm(ix),gv(iy),'k.');
hold off



%subplot(2,2,3);imagesc(gm,gv,reshape(c_imean,igv,igm));colorbar;title('imean')
%subplot(2,2,4);imagesc(reshape(c_var,iy,ix));colorbar;title('cvar')
