% visim_plot_kernel2 : plots VISIM simulations
%
% V=visim_plot_kernel2(V,ivol)
%
function visim_plot_kernel2(V,ivol,G,doPlot)

  if nargin<4
    doPlot=0;
  end
  
  if isstruct(V)~=1
    V=read_visim(V);
  end

  if nargin==1;
    ivol=1:size(V.fvolsum.data,1);
  end
	  
  if nargin<3
    G=visim_to_G(V);
  end

  [yy,xx]=meshgrid(V.y,V.x);
  for iv=1:length(ivol)
    gg=G(ivol(iv),:)';
    k=reshape(gg,V.nx,V.ny)';
    ig=find(gg>0);	
    plot(xx(ig),yy(ig),'k.','MarkerSize',20)
hold on
    scatter(xx(ig),yy(ig),18,k(ig).*0+V.fvolsum.data(ivol(iv),3),'filled')
hold off
  end	
  
  return
  

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