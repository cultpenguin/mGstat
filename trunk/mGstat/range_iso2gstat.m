% range_iso2gstat : convert range sacling to gstat/gslib range settings
function V=range_iso2gstat(V);

  for iV=1:length(V),
    
  
    ndim=length(V(iV).par2);
    
    if ndim==2,
      % 2 dimensional scaling
      if (V(iV).par2(1)>V(iV).par2(2))
        V(iV).par2=[V(iV).par2(1) 90 V(iV).par2(2)/V(iV).par2(1)];
      else
        V(iV).par2=[V(iV).par2(2) 0 V(iV).par2(1)/V(iV).par2(2)];
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
          r=90;
          s=rx/ry;
          t=rz/ry;
        else          
          % Z-dir secondary direction
          r=0;
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
          r=0;
          s=rx/rz;
          t=ry/rz;
        else
          % Y-dir secondary direction
          r=90;
          s=ry/rz;
          t=rx/rz;
        end
      end
      V(iV).par2=[a p q r s t];
      
    end
    
    
  end
