% visim_plot_condtab
%
% CALL :
%   visim_plot_condtab(V,doPrint)
%
function visim_plot_condtab(V,doPrint)
  
  if nargin==1, 
    doPrint=0;
  end
  MS=4;
  
  [p,f]=fileparts(V.parfile);
  
  fcmean=sprintf('cond_mean_%s',V.out.fname);
  fcvar=sprintf('cond_var_%s',V.out.fname);
  fk=sprintf('kriging_%s',V.out.fname);
  
  cmean=load(fcmean);
  cvar=load(fcvar);
  
  plot(cmean,cvar,'k.','MarkerSize',2*MS)
  
  xlabel('Mean')
  ylabel('Variance')
  legend('Lookup Table')
  
  
  if exist(fk)
    k=load(fk);
    kmean=k(:,1);
    kvar=k(:,2).^2;
    
    colormap(1-gray)
    hold on  
    % plot(kmean,kvar,'go','MarkerSize',MS*2)
    scatter_dot(kmean,kvar,MS*3,kmean.*0)
    caxis([0 1])
    hold off
    
    legend('Lookup Table','Kriging')
  end
  
  
  set(gca,'FontSize',12)
  
  if doPrint==1
    [f1,f2,f3]=fileparts(V.parfile);
    print_mul(sprintf('%s_condtab',f2))
  end
 