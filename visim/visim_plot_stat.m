% visim_plot_statm : plots statistics
%
% visim_plot_stat(V)
%
function visim_plot_stat(V,doPrint)
  
  if isstruct(V)~=1
    V=read_visim(V);
  end
  
  if nargin<2
    doPrint=1;
  end
  
  cax=[.09 .16];
  XLim=[-1 1].*.02;
  
  doPrintSub=0;

  FS=6;
  
  subplot(2,3,1);
  visim_plot_hist(V,doPrintSub);
  set(gca,'FontSize',FS);

  subplot(2,3,2);
%  visim_plot_semivar(V,1:V.nsim,doPrintSub);
  visim_plot_semivar(V,1:5,doPrintSub);
  set(gca,'FontSize',FS);

  subplot(2,3,3);
  visim_plot_volfit(V,XLim,doPrintSub);
  set(gca,'FontSize',FS);
 
    
  [f1,f2,f3]=fileparts(V.parfile);
  if doPrint==1
    print_mul(sprintf('%s_stat',f2))
  end
  