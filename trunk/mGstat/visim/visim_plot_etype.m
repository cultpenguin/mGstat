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
    
  
  if V.nsim==0
    %  if ~isfield(V,'etype')
    %      [d]=read_eas(['visim_estimation_',V.out.fname]);
    %      etype.mean=reshape(d(:,1),V.nx,V.ny);
    %      etype.var=reshape(d(:,2),V.nx,V.ny);
    %  end
    etype=V.etype;
  else
    etype=V.etype;
  end
  
  if info>0, subplot(1,2,1); end
  imagesc(V.x, V.y, etype.mean');
  set(gca,'XAxisLocation','top','FontSize',12)
  axis image
  if exist('cax1')==1
    caxis(cax1);
  end

  if info>0
    colorbar;
  end

  if V.nsim==0
    title(sprintf('LSQ mean'))
  else
    title(sprintf('E-type mean'))
  end
  
  if info>0
    
    subplot(1,2,2)
    imagesc(V.x, V.y, etype.var');
    set(gca,'XAxisLocation','top','FontSize',12)
    if exist('cax2')==1
      caxis(cax2);
    end
    colorbar;
    axis image
    if V.nsim==0
      title(sprintf([V.parfile,' - LSQ var']),'interpr','none')
    else
      title(sprintf('E-type var'))
    end
  end
    
  
  [f1,f2,f3]=fileparts(V.parfile);
  % title([f2],'interpr','none')

  if info>1
    print_mul(sprintf('%s_etype',f2))
  end
