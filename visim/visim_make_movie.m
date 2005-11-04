% visim_make_movie : Makes AVI movie of 2d simulations
%
%  
%
function M=visim_make_movie(V,nsim,cax)
  
  if isstruct(V)~=1
    V=read_visim(V);
  end

  if nargin<2, 
    nsim=V.nsim;
  end
  
  if nargin<3, 
    cax=[min(V.out.data) max(V.out.data)];
  end
  
  for i=1:nsim;
    imagesc(V.x,V.y,V.D(:,:,i)');
    axis image;
    caxis(cax);
    M(i)=getframe;
  end
    
  [f1,f2,f3]=fileparts(V.parfile);
  movie2avi(M,(sprintf('%s.avi',f2)))
  
  