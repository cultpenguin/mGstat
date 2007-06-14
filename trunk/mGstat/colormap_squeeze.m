% colormap_squeeze
%
% Call :
%   colormap_squeeze(dperc);
%   dperc=[0 .. 0.5];
%
%   imagesc(peaks);
%   colormap_squeeze(.1);
%   pause(1);
%   colormap_squeeze(.1);
%

function colormap_squeeze(dperc);

    
    if nargin==0
        dperc=[.1];
    end
    if length(dperc)==1
        dperc(2)=dperc(1);
    end
    
    cax=caxis;
    cxr=cax(2)-cax(1);
    cax(1)=cax(1)+dperc(1)*cxr;
    cax(2)=cax(2)-dperc(2)*cxr;
    caxis(cax)
    