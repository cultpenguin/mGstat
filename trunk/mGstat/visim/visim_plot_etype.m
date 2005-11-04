% visim_plot_etype : plots etype for VISIM run
%
% Call : 
%    visim_plot_etype(parfile);
%    visim_plot_etype(V); % V is a structure as read from read_visim
%    visim_plot_etype(parfile,info=1); % plots info on separate axis
%    visim_plot_etype(parfile,info=0); % plots NO info
%    visim_plot_etype(parfile,info=0,cax1=[0 1]); % Use cax for etype mean
%    visim_plot_etype(parfile,info=0,cax1=[0 1],cax2=[0 1]); % Use cax2 for etype var
%    V=visim_plot_etype(parfile);  % returns VISIM structure.
%
%
function V=visim_plot_etype(V,info,cax1,cax2)
  
  if isstruct(V)~=1
    V=read_visim(V);
  end
  if isstruct(V)~=1
    V=read_visim(V);
  end

  if nargin==1, 
    info=0;
  end
    
  
  clf;
  
  subplot(1,2+info,1)
  imagesc(V.x, V.y, V.etype.mean');
  axis image
  if exist('cax1')==1
    caxis(cax1);
  end
  colorbar;
  title(sprintf('E-type mean'))
  
  subplot(1,2+info,2)
  imagesc(V.x, V.y, V.etype.var');
  if exist('cax2')==1
    caxis(cax2);
  end
  colorbar;
  axis image
  title(sprintf('E-type variance'))
  
  if info==1
    subplot(1,3,3)
    axis off
    text(0.01,.8,V.parfile,'units','normalized','Interpreter','none')
    text(0.01,.7,sprintf('nsim=%d',V.nsim),'units','normalized','Interpreter','none')
    drawnow;pause(1)
  end
  
  [f1,f2,f3]=fileparts(V.parfile);
  title([f2,' E-type'],'interpr','none')

  print_mul(sprintf('%s_etype',f2))