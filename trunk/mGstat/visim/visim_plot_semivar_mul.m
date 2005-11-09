function visim_plot_semivar_mul(V,name,cax)

%V{1}=read_visim('visim_25_geomod.par');
%V{2}=read_visim('visim_25_geomod_unc.par');
%name{1}='cond';
%name{2}='uncond';

ang=[0 90];
tolerance=15;
isim=1:100;

col{1}=[0 0 0];
col{2}=[1 0 0];
col{3}=[0 0 1];
lstyle{1}=('-');
lstyle{2}=('--');
lstyle{3}=(':');

for iv=1:length(V);
  for ia=1:length(ang)
    a(ia)=V{iv}.Va.ang1+ang(ia);
    [g{ia}{iv},hc{ia}{iv}]=visim_semivar(V{iv},isim,a(ia),tolerance);
  end
end


i=0;
for ia=1:length(ang)
for iv=1:length(V);
  i=i+1;
  %subplot(3,3,i)
  pall=plot(hc{ia}{iv},mean(g{ia}{iv}')','-','color',col{iv},'linestyle',lstyle{ia});
  p(i)=pall(1);
  
  
  leg{i}=sprintf('%s, %3.1f',name{iv},a(ia));
  
  if i==1; hold on; end
end
end
hold off
  
[v1,v2]=visim_format_variogram(V{1});
v1=deformat_variogram(v1);
v2=deformat_variogram(v2);
hc2=linspace(0,max(hc{1}{1}),40);
[sv1]=semivar_synth(v1,hc2,0);  
[sv2]=semivar_synth(v2,hc2,0);  
hold on
p(i+1)=plot(hc2,sv1,'k','linewidth',3,'linestyle',lstyle{1});
p(i+2)=plot(hc2,sv2,'k','linewidth',3,'linestyle',lstyle{2});
leg{i+1}='hx prim';
leg{i+2}='hx sec';

legend(p,leg,0)

xlabel('Distance')
ylabel('Semivariance, \gamma')


[f1,f2,f3]=fileparts(V{1}.parfile);
print_mul(sprintf('%s_semivar_mul',f2))
