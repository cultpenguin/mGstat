% visim_plot_statm : plots statistics
function M=visim_make_movie(V,nsim,cax)
  
  if isstruct(V)~=1
    V=read_visim(V);
  end

  [hall,xall]=hist(V.out.data,30);
  
  for i=1:V.nsim
    d=V.D(:,:,i);d=d(:);
    [h(i,:)]=hist(d,xall);
  end
  
  orgpdf=normpdf(xall,V.gmean,sqrt(V.gvar));
  orgpdf=V.nx*V.ny*V.nz*orgpdf./(sum(orgpdf));  

  hall=V.nx*V.ny*V.nz*hall./sum(hall);
  
  subplot(1,1,1);
  l0=plot(xall,h,'k-','linewidth',.1);
  hold on
  l1=plot(xall,hall,'g--','linewidth',3);
  l2=plot(xall,orgpdf,'r--','linewidth',3);
  hold off
  xlabel('Value');ylabel('#counts')
  legend([l2 l1 l0(1)],'A priori','All realizations','Relisations')
  
  x0=0.03;
  text(x0,.9,'A priori :','units','norm')
  text(x0,.85,sprintf('mean=%6.3f',V.gmean),'units','norm')
  text(x0,.8,sprintf('var=%6.3g',V.gvar),'units','norm')
  text(x0,.75,sprintf('std=%6.3g',sqrt(V.gvar)),'units','norm')

    
  x0=0.03;
  text(x0,.65,'Simulations :','units','norm')
  text(x0,.60,sprintf('mean=%6.3f',mean(V.out.data)),'units','norm')
  text(x0,.55,sprintf('var=%6.3g',var(V.out.data)),'units','norm')
  text(x0,.50,sprintf('std=%6.3g',std(V.out.data)),'units','norm')
  

  [f1,f2,f3]=fileparts(V.parfile);

  title(f2,'interpr','none')

  print_mul(sprintf('%s_stat',f2))
  
 
  
  
  