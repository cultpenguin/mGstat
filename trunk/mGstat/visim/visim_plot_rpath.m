function visim_plot_rpath(V,nshow,doPrint,PlotOnlyRays)

  if isstruct(V)~=1
    V=read_visim(V);
  end

  nxy=V.nx*V.ny;
  
  if nargin<2,
    nshow=500;
    nshow=nxy;
    nshow=430;
  end
  
  if nargin<3
    doPrint=1;
  end

  if nargin<4
    PlotOnlyRays=0;
  end
  
  G=visim_to_G(V);
  
  
    
  S=reshape(sum(G),V.nx,V.ny)';  
  
  rp_file=sprintf('randpath_%s',V.out.fname);
  
  if exist(rp_file)==0
    disp(sprintf('Could not find %s.',rp_file))
    disp(['Exiting....'])
    return
  end
  
  rp=load(rp_file);
  
  rpi=rp(:,3);
  
  clear ix iy;
  imagesc(V.x,V.y,S);caxis([0 0.001]);axis image
  cmap=1-gray(64);
  colormap(cmap(1:12,:))
  
  if PlotOnlyRays==1,
    title('Ray coverage')
  else
    hold on
    for i=1:nshow;
      [ix(i),iy(i)]=ind2sub([V.nx V.ny],rpi(i));
      MS=20-20*(i/nshow)+.1;
      plot(V.x(ix(i)),V.y(iy(i)),'k.','MarkerSize',MS)
    end
    hold off
    
    if V.densitypr==0
      tit='Independent';
    elseif V.densitypr==1
      tit='Volumes first';
    elseif V.densitypr>1
      tit='Preferential';
    end  
    
    title(tit)
  end
  [f1,f2,f3]=fileparts(V.parfile);
  if doPrint==1
    print_mul(sprintf('%s_%d_rpath',f2,V.densitypr))
  end
