function visim_semivar_uncon(Vu,V)

  if isstruct(Vu)~=1
    Vu=read_visim(Vu);
  end
  
  for i=1:length(V)
    if isstruct(V{i})~=1
      V{i}=read_visim(V{i});
    end
  end
  
  %Vu=read_visim('visim_25_geomod_unc.par');
  %V{1}=read_visim('visim_25_geomod.par');
   
  ang=[0 90]+Vu.Va.ang1;
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
  
  isim=1:Vu.nsim;
%  isim=1:10;
      
  [v1,v2]=visim_format_variogram(Vu);
  v1=deformat_variogram(v1);
  v2=deformat_variogram(v2);
  hc_orig=linspace(0,5,40);
  [sv1]=semivar_synth(v1,hc_orig,0);  
  [sv2]=semivar_synth(v2,hc_orig,0);  
  
  sv_orig(:,1)=sv1;
  sv_orig(:,2)=sv2;
  
  
  ia=1;

    
  for ia=1:length(ang)
    
    
    [g,hc]=visim_semivar(Vu,isim,ang(ia),tolerance);
    
    garr=linspace(0,.7*max(g(:)),20);
    [gmat,gc,p5,p50,p95]=semivar_mat(hc,g,garr);
    
    for iv=1:length(V),
      [Mg{iv},Mhc{iv}]=visim_semivar(V{iv},isim,ang(iv),tolerance);
      
      [Mgmat{iv},Mgc{iv},Mp5{iv},Mp50{iv},Mp95{iv}]=semivar_mat(Mhc{iv},Mg{iv},garr);
      
    end
    
    figure
    plot(hc,g,'k-','linewidth',.1)
    figure
    
    imagesc(hc,garr,gmat);
    colormap(1-gray)
    caxis([0 .6*length(isim)])
    hold on

    ip=1;
    p(ip)=plot(hc_orig,sv_orig(:,ia),'-','linewidth',5,'color',[.5 ...
                   .5 .5]);
    leg{ip}='A priori';
    
    ip=ip+1;
    p(ip)=plot(hc,mean(g')','k-','linewidth',3);
    leg{ip}='Uncon';
    for iv=1:length(V)
      
      ip=ip+1;
      p(ip)=plot(hc,p5,'k-.','linewidth',.1);
      leg{ip}='Uncond p5';
      
      ip=ip+1;
      p(ip)=plot(hc,p95,'k-.','linewidth',.1);
      leg{ip}='Uncond p95';
      
      ip=ip+1;
      p(ip)=plot(Mhc{iv},Mp5{iv},'r-.','linewidth',.1);
      leg{ip}='Cond p5';
      
      ip=ip+1;
      p(ip)=plot(Mhc{iv},Mp95{iv},'r--','linewidth',.1);
      leg{ip}='Cond p95';
      
      ip=ip+1; 
      p(ip)=plot(Mhc{iv},Mp50{iv},'r-','linewidth',2);
      leg{ip}='Cond p50';
      
    end

    legend(p,leg)
    
    
    hold off
    
    set(gca,'ydir','normal')
    
    
    
    [f1,f2,f3]=fileparts(Vu.parfile);
    print_mul(sprintf('%s_%f_semivar_comp',f2,ang(ia)))
  end