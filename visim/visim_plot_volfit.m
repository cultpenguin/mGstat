% visim_plot_vol_fit : Plot Histogram of d_obs<>d_est
function [m_est]=visim_plot_volfit(V);
  
  if isstruct(V)~=1
    V=read_visim(V);
  end
  
  [G,d_obs,d_var]=visim_to_G(V);

  
  nxyz=size(G,2);
  nvol=size(G,1);

  for i=1:V.nsim
    m=V.D(:,:,i);
    d_est(:,i)=G*m(:);
    d_dif(:,i)=G*m(:)-d_obs;
  end
  
  hist(d_dif(:),max([10 V.nsim]))
  
      
  x0=0.03;
  text(x0,.90,sprintf('mean=%6.3f',mean(d_dif(:))),'units','norm')
  text(x0,.85,sprintf('var=%6.3g',var(d_dif(:))),'units','norm')
  text(x0,.80,sprintf('std=%6.3g',std(d_dif(:))),'units','norm')
 
  [f1,f2,f3]=fileparts(V.parfile);

  title([f2,' Data Fit'],'interpr','none')

  print_mul(sprintf('%s_volfit',f2))
  