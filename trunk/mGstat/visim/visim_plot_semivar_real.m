% visim_plot_semivar_real(V,name,cax)
function visim_plot_semivar_real(V,name,cax)

ang=[0 90];
tolerance=15;

col{1}=[0 0 0];
col{2}=[1 0 0];
col{3}=[0 0 1];
lstyle{1}=('-');
lstyle{2}=('--');
lstyle{3}=(':');

for ia=1:length(ang)
    a(ia)=V.Va.ang1+ang(ia);
    [g{ia},hc{ia}]=visim_semivar(V,1:V.nsim,a(ia),tolerance);
end

  
[v1,v2]=visim_format_variogram(V);
vtxt{1}=v1;
vtxt{2}=v2;

v1=deformat_variogram(v1);
v2=deformat_variogram(v2);
hc2=linspace(0,max(hc{1}),40);
[sv{1}]=semivar_synth(v1,hc2,0);  
[sv{2}]=semivar_synth(v2,hc2,0);  


i=0;
for ia=1:length(ang)
  i=i+1;
  subplot(2,2,i)
  pall=plot(hc{ia},g{ia},'-','color',[1 1 1].*.7,'linewidth',.1);
  pall=pall(1);
  hold on
  pmean=plot(hc{ia},mean(g{ia}')','-','color',col{1},'linestyle',lstyle{ia});
  p(i)=pall(1);
  
  ptrue=plot(hc2,sv{i},'k-','linewidth',3,'linestyle',lstyle{1});
  
  l=legend([pall,pmean,ptrue],'All Sim','Mean',vtxt{ia});
%  set(l,'Location','SouthEast');
  set(l,'Location','Best');

  xlabel('Distance')
  ylabel('Semivariance, \gamma')
  
  axis([0 max(hc2) 0 V.Va.cc*1.3])
  
end
hold off



[f1,f2,f3]=fileparts(V.parfile);
print_mul(sprintf('%s_semivar_real',f2))

