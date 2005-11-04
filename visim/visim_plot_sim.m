% visim_plot_sim : plots VISIM simulations
%
function V=visim_plot_sim(V,nsim,cax)
  
  if isstruct(V)~=1
    V=read_visim(V);
  end

  if nargin<2, 
    nsim=V.nsim;
  end
  
  if nargin<3, 
    cax=[min(V.out.data) max(V.out.data)];
  end
  
  
  dxy=V.nx/V.ny;
  
  nxsub=max([1 floor(nsim*dxy)]);
  nysub=ceil(nsim/nxsub);
  
  for i=1:nsim;
    subplot(nysub,nxsub,i)
    imagesc(V.x,V.y,V.D(:,:,i)');
    title(sprintf('#%d',i));
    caxis(cax);
    axis image
  end
  colorbar
  
  [f1,f2,f3]=fileparts(V.parfile);
  title([f2,' Realizations'],'interpr','none')

  
  print_mul(sprintf('%s_sim',f2))