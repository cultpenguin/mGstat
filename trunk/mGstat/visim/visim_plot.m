% visim_plot(V,cax);

function visim_plot(V,cax);
  
  if isstruct(V)~=1
    V=read_visim(V);
  end
  
  if nargin==1,
    cax=[min(V.out.data) max(V.out.data)];
  end
  
  colormap(gray);cmap=colormap;
  
  figure;colormap(cmap)
  visim_plot_volfit(V);
  figure;;colormap(cmap)
  visim_plot_stat(V);
  figure;;colormap(cmap)
  visim_plot_etype(V,0,cax);
  figure;;colormap(cmap)
  visim_plot_sim(V,min([V.nsim 16]),cax);
  figure;;colormap(cmap)
  visim_make_movie(V,min([V.nsim 10]),cax)
  