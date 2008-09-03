function [data,header,title,O]=sgems_read_pointset(filename);
%
%
% Example
%
% Convert SGEMS POINTSET to EAS file
% [data,header,title]=sgems_read_pointset('pointset.sgems');
% write_eas('pointset.eas',data,header,title);
%

O=sgems_read(filename);

data=[O.xyz O.data];
title=O.point_set;
ndim=size(O.xyz,2);
for i=1:ndim
    if i==1,header{i}='X'; end
    if i==2,header{i}='Y'; end
    if i==3,header{i}='Z'; end
end

for i=1:O.n_prop
    header{i+ndim}=O.property_name{i};
end
   
