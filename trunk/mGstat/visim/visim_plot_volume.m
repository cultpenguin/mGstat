% visim_plot_volume : plots volume coverage
%
% visim_plot_volume(V,ivol)
%
function visim_plot_volume(V,ivol)
     
  if isstruct(V)~=1
    V=read_visim(V);
  end

  nvol=size(V.fvolsum.data,1);
  
  if nargin<2
    ivol=1:1:nvol;
  end

  cax=[min(V.fvolsum.data(:,3)) max(V.fvolsum.data(:,3))];
  ax=[min(V.x) max(V.x) min(V.y) max(V.y)];
  
  
  for iv=1:length(ivol)
    ii=find(V.fvolgeom.data(:,4)==ivol(iv));

    x=V.fvolgeom.data(ii,1);
    y=V.fvolgeom.data(ii,2);
    z=V.fvolgeom.data(ii,3);

    vel=V.fvolsum.data(iv,3);
    
    scatter(x,y,20,x.*0+vel,'filled')
      caxis(cax)
    axis image 
    axis (ax)
    
  
    if iv==1;
      hold on
    end
  
  end
    
  set(gca,'ydir','revers')
  hold off