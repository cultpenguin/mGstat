% visim_plot_vol_fit : Plot Histogram of d_obs<>d_est
%
% [d_dif,d_obs,d_var]=visim_plot_volfit(V,Xlim,doPrint,rayl,rayt);
%
function [d_dif,d_est,d_obs,d_var]=visim_plot_volfit(V,Xlim,doPrint,rayl,rayt);
  
  if isstruct(V)~=1
    V=read_visim(V);
  end

  if nargin<3
    doPrint=1;
  end
  
  FS=12;
  
  [G,d_obs,d_var]=visim_to_G(V);

  
  nxyz=size(G,2);
  nvol=size(G,1);

  for i=1:V.nsim
    m=V.D(:,:,i);
    d_est(:,i)=G*m(:);
    if nargin>=4
      d_dif(:,i)= rayl./d_est(:,i)-rayt;
    else
      d_dif(:,i)=G*m(:)-d_obs;
    end
  end  
  if V.nsim==0;
    m=V.etype.mean;
    d_est=G*m(:);
    d_dif=d_est-d_obs;
  end    
  
  hist(d_dif(:),max([10 V.nsim]))
  
      
  x0=0.03;
  text(x0,.90,sprintf('mean=%6.3g',mean(d_dif(:))),'units','norm','FontSize',FS)
  text(x0,.85,sprintf('var=%5.3g',var(d_dif(:))),'units','norm','FontSize',FS)
  text(x0,.80,sprintf('std=%4.3g',std(d_dif(:))),'units','norm','FontSize',FS)
  
  if nargin>1
    if ~isempty(Xlim)
      set(gca,'Xlim',Xlim)
    end
  end
  
  xlabel('Data Misfit (d_{est}-d_{obs})')
  ylabel('# Count')
  
  [f1,f2,f3]=fileparts(V.parfile);

  % title([f2,' Data Fit'],'interpr','none')

  if doPrint==1
    print_mul(sprintf('%s_volfit',f2))
  end
  
