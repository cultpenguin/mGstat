% visim_plot_kernel : plots VISIM simulations
%
% V=visim_plot_kernel(V,ivol)
%
function visim_plot_kernel(V,ivol,G,doPlot)

  if nargin<4
    doPlot=0;
  end
  
  if isstruct(V)~=1
    V=read_visim(V);
  end

  if isfield(V,'fvolsum')
    
    if nargin==1;
      ivol=1:size(V.fvolsum.data,1);
    end
    
    if nargin<3
      G=visim_to_G(V);
    end
    
    if length(ivol)==1
      gg=G(ivol,:);
    else
      gg=sum(G(ivol,:));
    end
    
    imagesc(V.x,V.y,reshape(gg,V.nx,V.ny)');
    axis image
    txt=title(sprintf('Kernel for  %s',V.parfile));
    set(txt,'interpreter','none');
  
    hold on
    
  end
  
  if (isfield(V,'fconddata'))
    d=V.fconddata.data;
    %scatter( d(:,V.cols(1)), d(:,V.cols(2)), 20 , d(:,V.cols(4)) )
    plot( d(:,V.cols(1)), d(:,V.cols(2)), 'r*')
  end
  
  hold off
  
  axis([V.x(1) max(V.x) V.y(1) max(V.y)])
  axis image
  
  
  if doPlot>0
    
    [f1,f2,f3]=fileparts(V.parfile);
    
    print_mul(sprintf('%s_kernel',f2))
  end