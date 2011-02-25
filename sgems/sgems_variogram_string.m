% sgems_variogram_xml : convert SGEMS XML variogram into STRING (gstat style) 
%
% Call : 
%    XML=sgems_variogram_xml(Va);
%
% Example : 
%    var_xml=sgems_variogram_xml('0.1 Nug(0) + 0.4 Exp(10) + 0.5 Sph(40,30,0.2)');
%    S.XML.parameters.Variogram = var_xml;
%    variogram_string = sgems_variogram_string(var_xml);
%    disp(sprintf('Variogram =  ''%s''',variogram_string))
%
% The STRING format for a variogram model is the same as used in GSTAT :
% http://www.gstat.org/gstat.pdf
%

function str=sgems_variogram_string(XML)

str='';
if XML.nugget~=0
    str=sprintf('%g Nug(0)',XML.nugget);
else 
    str='';
end

for i=1:XML.structures_count
    if length(str)>0
        str=sprintf('%s + ',str);
    end
    
    v=XML.(sprintf('structure_%d',i));
    str=sprintf('%s%g %s',str,v.contribution,v.type(1:3));
    if (v.ranges.max==v.ranges.medium) & (v.ranges.max==v.ranges.min);
        str=sprintf('%s(%g)',str,v.ranges.max);
    else
        a=v.ranges.max; 
        p=v.angles.x;
        q=v.angles.y; 
        r=v.angles.z; 
        s=v.ranges.medium/v.ranges.max; 
        t=v.ranges.min/v.ranges.max;
        str=sprintf('%s(%g,%g,%g,%g,%g,%g)',str,a,p,q,r,s,t);
    end
end
    
    
end
