% visim_plot_hist : plots statistics
%
% visim_plot_hist(V)
%
function visim_plot_hist(V,doPrint)
     
  if isstruct(V)~=1
    V=read_visim(V);
  end

  if nargin==1
    doPrint=1;
  end
    
  
  [hall,xall]=hist(V.out.data,30);
  
  for i=1:V.nsim
    d=V.D(:,:,i);d=d(:);
    [h(i,:)]=hist(d,xall);
  end

  
 FS=5;
  
  orgpdf=normpdf(xall,V.gmean,sqrt(V.gvar));
  orgpdf=V.nx*V.ny*V.nz*orgpdf./(sum(orgpdf));  

  hall=V.nx*V.ny*V.nz*hall./sum(hall);
  
    
  
  l0=plot(xall,h,'k-','linewidth',.1);
  hold on
  l1=plot(xall,hall,'g--','linewidth',1);
  l2=plot(xall,orgpdf,'r-+','linewidth',1);
  hold off
  xlabel('Value');ylabel('#counts')
  l=legend([l2 l1 l0(1)],'A priori','All real','Real');
  set(l,'FontSize',5)
  
  x0=0.03;
  text(x0,.9,'A priori :','units','norm','FontSize',FS)
  text(x0,.85,sprintf('mean=%6.3f',V.gmean),'units','norm','FontSize',FS)
  text(x0,.8,sprintf('var=%6.3g',V.gvar),'units','norm','FontSize',FS)
  text(x0,.75,sprintf('std=%6.3g',sqrt(V.gvar)),'units','norm','FontSize',FS)

    
  x0=0.03;
  text(x0,.65,'Simulations :','units','norm','FontSize',FS)
  text(x0,.60,sprintf('mean=%6.3f',mean(V.out.data)),'units','norm','FontSize',FS)
  text(x0,.55,sprintf('var=%6.3g',var(V.out.data)),'units','norm','FontSize',FS)
  text(x0,.50,sprintf('std=%6.3g',std(V.out.data)),'units','norm','FontSize',FS)
  
  

  [f1,f2,f3]=fileparts(V.parfile);

  % title(f2,'interpr','none')
  
  if doPrint==1
    print_mul(sprintf('%s_stat',f2))
  end
 
  
  
  