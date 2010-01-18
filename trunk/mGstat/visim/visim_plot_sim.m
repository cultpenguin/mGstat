% visim_plot_sim : plots VISIM simulations
%
% V=visim_plot_sim(V,isim,cax,FS,nxsub,nysub)
%
% V: VISIM structure
% isim (optional): realization numbers to plot: def:isim=1:1:V.nsim;
% cax  (optional): Coloraxis, def:cax=[min(V.out.data) max(V.out.data)];
% FS   (optional): Fontsize, def:FS=6;
% nxsub (optional): number of subplot i X direction 
% nzyub (optional): number of subplot i Y direction 
%

function V=visim_plot_sim(V,isim,cax,FS,nxsub,nysub)

  if isstruct(V)~=1, V=read_visim(V); end
  if nargin<2, isim=1:1:V.nsim; end
  if isempty(isim), isim=1:1:V.nsim;  end  
  nsim=length(isim);
  
  if nargin<3, cax=[min(V.out.data) max(V.out.data)]; end
  
  if nargin<4, FS=6; end
  if isempty(FS), FS=6; end
  
  if nargin<5
    dxy=V.nx/V.ny;
    nxsub=max([1 floor(sqrt(nsim)*dxy)]);
  end
  if nargin<6
    nysub=ceil(nsim/nxsub);
  end
  
  j=0;
  for i=1:nsim;
      j=j+1;
      %  for i=1:min(nsim,(nxsub*nysub));
    subplot(nysub,nxsub,i)
    imagesc(V.x,V.y,V.D(:,:,isim(j))');
    % title(sprintf('#%d',i),'FontSize',FS+2);
    caxis(cax);
    set(gca,'FontSize',FS)
    set(gca,'XAxisLocation','top')
    axis image
    title(sprintf('i=%03d',isim(j)))
  end
 
  %set(gca,'visible','off');  colorbar;  cla
  [f1,f2,f3]=fileparts(V.parfile);
  %title([f2,' Realizations'],'interpr','none')
  
  %print_mul(sprintf('%s_sim',f2))
