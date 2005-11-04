function visim_plot(V,cax);
  
  if isstruct(V)~=1
    V=read_visim(V);
  end
  
  if nargin==1,
    cax=[min(V.out.data) max(V.out.data)];
  end
  
  figure;
  visim_plot_volfit(V);
  figure;
  visim_plot_stat(V);
  figure;
  visim_plot_etype(V,0,cax);
  figure;
  visim_plot_sim(V,min([V.nsim 16]),[0.1 0.16]);
  figure;
  visim_make_movie(V,min([V.nsim 10]),cax)
  