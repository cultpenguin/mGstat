% visim_plot_sim : plots VISIM simulations
%
% V=visim_plot_sim(V,nsim,cax,FS,nxsub,nysub)
%
function V=visim_plot_sim(V,nsim,cax,FS,nxsub,nysub)

  if isstruct(V)~=1
    V=read_visim(V);
  end

  if nargin<2, 
    nsim=V.nsim;
  end
  
  if nargin<3, 
    cax=[min(V.out.data) max(V.out.data)];
  end
  
  if nargin<4, 
    FS=6;
  end
  if isempty(FS)
    FS=6;
  end
  
  if nargin<5
    dxy=V.nx/V.ny  ;
    nxsub=max([1 floor(nsim*dxy)]);
  end
  if nargin<6
    nysub=ceil(nsim/nxsub);
  end
  
%  for i=1:nsim;
  for i=1:(nxsub*nysub);
    subplot(nysub,nxsub,i)
    imagesc(V.x,V.y,V.D(:,:,i)');
    % title(sprintf('#%d',i),'FontSize',FS+2);
    caxis(cax);
    set(gca,'FontSize',FS)
    set(gca,'XaxisL','top')
    axis image
  end
  %set(gca,'visible','off');  colorbar;  cla
  [f1,f2,f3]=fileparts(V.parfile);
  %title([f2,' Realizations'],'interpr','none')
  
  print_mul(sprintf('%s_sim',f2))
