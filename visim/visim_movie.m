% visim_movie : Show movie of visim realizations
%
% M=visim_movie(V,ivol,cax,fps)
%
%
% Example : 
%   M=visim_movie('visim.par');
%   movie(M,[1:10],[.11 .15],1)
%
%  fps : frames per second.
%
%
% CURRENTLY ONLY WORKS FOR 2D
%
%
function M=visim_movie(V,ivol,cax,fps)

  if nargin<4
      % DEFAULT FRAMES PER SETTING
    fps=4;
  end
  
  if isstruct(V)~=1
    V=read_visim(V);
  end

  
  if nargin<2
    ivol=1:size(V.D,3);
  end

  if ndims(V.D)~=3
      disp(sprintf('%s : only works for 2D movies at the time...', ...
                   mfilename));
      M=[];
  end
  
  
  if nargin <2
      cax=[min(V.D(:)) max(V.D(:))];
  end

  if nargout>0
    export_mov=1;
  else
    export_mov=0;
  end
  
  for i=ivol
      imagesc(V.x,V.y,V.D(:,:,i)');
      caxis(cax)
      axis image
      drawnow;
      if export_mov==1
          M(i)=getframe;
      end
  end
  
  if export_mov==1;
          
      [f1,f2,f3]=fileparts(V.parfile);
      filename=(sprintf('%s.avi',f2));
      mgstat_verbose(sprintf('%s : writing movie to %s',mfilename,filename),-1);
      
      movie2avi(M,filename,'FPS',fps);
      % EXPORT MOVIE
  else
      M=[];
  end
  