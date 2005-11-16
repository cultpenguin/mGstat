function V1=visim_plot_semivar(V1,isim,doPlot)
  
  if isstruct(V1)~=1
    V1=read_visim(V1);
  end
  
  if nargin<3
    doPlot=0;
  end

  if nargin<2
    isim=1:V.nsim;
  end
  
  method=1;
  
  di=10;
  i0=V1.Va.ang1;
  ang=[0 90]+i0;
  nang=length(ang);
  
  tolerance=15;

  
  col{1}=[0 0 0];
  col{2}=[1 0 0];
  col{3}=[0 0 1];
  lstyle{1}=('-');
  lstyle{2}=('--');
  lstyle{3}=(':');
  m{1}=('*');
  m{2}=('+');
  m{3}=('o');
  

  [g0,hc0]=visim_semivar(V1,isim,0,180);
  
  for i=1:nang
    
    [g,hc]=visim_semivar(V1,isim,ang(i),tolerance);
    
    if (length(isim)>1)&(method==1);
      pmg1(i)=plot(hc,mean(g')','b-','linewidth',i*2/4,'Marker',m{i});
      if i==1; hold on; end
    else
      pm1=plot(hc,g,'b-+','linewidth',i*2/4,'Marker',m{i});
      pmg1(i)=pm1(1);
      if i==1; hold on; end
    end
    drawnow;
    leg{i}=sprintf('%4.1f^o +/- %3.1f^o',ang(i),tolerance);
  end

  i=i+1;
  pmg1(i)=plot(hc0,mean(g0')','b-o','linewidth',1);  
  leg{i}='All directions';
  hold off
  
  L=(num2str(ang'));
  
  [v1,v2]=visim_format_variogram(V1);
  v1=deformat_variogram(v1);
  v2=deformat_variogram(v2);
  hc2=linspace(0,max(hc),40);
  [sv1]=semivar_synth(v1,hc2,0);  
  [sv2]=semivar_synth(v2,hc2,0);  
  hold on
  p1=plot(hc2,sv1,'k-','linewidth',1);
  p2=plot(hc2,sv2,'k--','linewidth',1);
  
  hold off

  
  leg{i+1}=[format_variogram(v1,1)];
  leg{i+2}=[format_variogram(v2,1)];  
  
  l=legend([pmg1 p1 p2],leg,4);
  set(l,'FontSize',5)
  
  
  xlabel('Distance')
  ylabel('\gamma')
  
  set(gca,'ylim',[0 1.1*sum([v1.par1])])
  
  [f1,f2,f3]=fileparts(V1.parfile);
  if doPlot==1
    print_mul(sprintf('%s_%d_semivar',f2,method))
  end
