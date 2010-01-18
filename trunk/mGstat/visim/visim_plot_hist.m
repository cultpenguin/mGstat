% visim_plot_hist : plots statistics
%
% visim_plot_hist(V,isim,doPrint)
%
function visim_plot_hist(V,isim,FS,doPrint)
     
  if isstruct(V)~=1
    V=read_visim(V);
  end

  if nargin<4
    doPrint=1;
  end

  if nargin<3
    FS=12;
  end


  if nargin<2
    isim=1:1:V.nsim;
  end

  if isempty(isim)
    isim=1:1:V.nsim;
  end
  
  
  if isempty(isim)
    isim=1:1:V.nsim;
  end


  d=V.D(:,:,isim);
  d=d(:);
  xall=linspace(.07,.19,40);
  [hall,xall]=hist(d,xall);
  [hall,xall]=hist(d,30);
  
  for i=1:V.nsim
    d=V.D(:,:,i);d=d(:);
    [h(i,:)]=hist(d,xall);
  end

  
  if V.ccdf==0
    orgpdf=normpdf(xall,V.gmean,sqrt(V.gvar));    
    orgpdf=V.nx*V.ny*V.nz*orgpdf./(sum(orgpdf));  
  else
    d=read_eas(V.refhist.fname);
    if (size(d,2)==1)
        orgpdf=hist(d,xall);
    else
        orgpdf=interp1(d(:,1),d(:,2),xall);
    end
    orgpdf=V.nx*V.ny*V.nz*orgpdf./(sum(orgpdf));      
  end
  hall=V.nx*V.ny*V.nz*hall./sum(hall);
  
    
  
  l0=plot(xall,h(isim,:)','-','linewidth',.1,'color',[.7 .7 .7]);
  hold on
  l1=plot(xall,hall,'k-','linewidth',2);
  l2=plot(xall,orgpdf,'k--','linewidth',2);
  hold off
  xlabel('Value');ylabel('# Counts')
		 
  try
  if length(isim)==1
    l=legend([l2 l1],'A priori','Realization',2);
  else
      l=legend([l2 l1 l0(1)],'A priori','Mean all real','All real',2);
  end
  set(l,'FontSize',14)
  end
  
  try
  x0=0.03;
  y0=0.7; 
  dy=.05;
  text(x0,y0,'A priori :','units','norm','FontSize',FS)
  text(x0,y0-1*dy,sprintf('mean=%6.3g',V.gmean),'units','norm','FontSize',FS)
  text(x0,y0-2*dy,sprintf('var=%5.3g',V.gvar),'units','norm','FontSize',FS)
  text(x0,y0-3*dy,sprintf('std=%4.3g',sqrt(V.gvar)),'units','norm','FontSize',FS)
  end
  
  try
  y0=.48;
  x0=0.03;
  text(x0,y0,'Simulations :','units','norm','FontSize',FS)
  text(x0,y0-1*dy,sprintf('mean=%6.3g',mean(V.out.data)),'units','norm','FontSize',FS)
  text(x0,y0-2*dy,sprintf('var=%5.3g',var(V.out.data)),'units','norm','FontSize',FS)
  text(x0,y0-3*dy,sprintf('std=%4.3g',std(V.out.data)),'units','norm','FontSize',FS)
  end
  Xlim=get(gca,'Xlim');
  Xlim=[Xlim(1)-(Xlim(2)-Xlim(1))*.1 Xlim(2)];
  set(gca,'Xlim',Xlim)
  

  [f1,f2,f3]=fileparts(V.parfile);

  % title(f2,'interpr','none')
  
  if doPrint==1
    print_mul(sprintf('%s_stat',f2))
  end
 
  
  
  