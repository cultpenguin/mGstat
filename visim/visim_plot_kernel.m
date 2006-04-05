% visim_plot_kernel : plots VISIM simulations
%
% V=visim_plot_kernel(V,ivol)
%
function visim_plot_kernel(V,ivol,doPlot)

  if nargin<3
    doPlot=0;
  end
  
  if isstruct(V)~=1
    V=read_visim(V);
  end

  if nargin==1;
    ivol=1:size(V.fvolsum.data,1);
  end
  
  G=visim_to_G(V);
    
  if length(ivol)==1
    gg=G(ivol,:);
  else
    gg=sum(G(ivol,:));
  end
  
  
  imagesc(V.x,V.y,reshape(gg,V.nx,V.ny)');
  axis image
  txt=title(sprintf('Kernel for  %s',V.parfile));
  set(txt,'interpreter','none');

  if doPlot>0
    
    [f1,f2,f3]=fileparts(V.parfile);
    
    print_mul(sprintf('%s_kernel',f2))
  end