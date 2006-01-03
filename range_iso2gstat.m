% range_iso2gstat : convert range scaling to gstat/gslib range settings
%
%
% for example
%   V = '1.0 Sph(0.7,0.8,0.9)';
%
%   Vgstat=isorange(V)
%
% Used when 'options.isorange=1'
%

function V=range_iso2gstat(V);

  if isstruct(V)==0
    V=deformat_variogram(V);
  end
  
  for iV=1:length(V),
    
  
    ndim=length(V(iV).par2);
    
    if ndim==2,
      % 2 dimensional scaling
      rx=V(iV).par2(1);
      ry=V(iV).par2(2);
      if (rx>ry)
        V(iV).par2=[rx 90 ry/rx];
      else
        V(iV).par2=[ry  0 rx/ry];
      end
    end
  
    
    if ndim==3,

      % 3 dimensional scaling
      rx=V(iV).par2(1);
      ry=V(iV).par2(2);
      rz=V(iV).par2(3);
      
      if ((rx>ry)&(rx>rz))
        % X-dir the principal direction
        p=90;
        q=0;
        a=rx;
        if (ry>rz)
          % Y-dir secondary direction
          r=0;
          s=ry/rx;
          t=rz/rx;
        else
          % Z-dir secondary direction
          r=90;
          s=rz/rx;
          t=ry/rx;
        end
        
      elseif ((ry>rx)&(ry>rz))
        % Y-dir the principal direction
        p=0;
        q=0;
        a=ry;
        if (rx>rz)
          % X-dir secondary direction
          r=0;
          s=rx/ry;
          t=rz/ry;
        else          
          % Z-dir secondary direction
          r=90;
          s=rz/ry;
          t=rx/ry;
        end
        
      else
        % Z-dir the principal direction
        p=90;
        q=360-90;
        a=rz;
        if (rx>ry)
          % X-dir secondary direction
          r=90;
          s=rx/rz;
          t=ry/rz;
        else
          % Y-dir secondary direction
          r=0;
          s=ry/rz;
          t=rx/rz;
        end
      end
      V(iV).par2=[a p q r s t];
      
    end
    
    
  end
