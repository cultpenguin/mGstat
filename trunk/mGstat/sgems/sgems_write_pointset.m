function O=sgems_write_pointset(filename,data,header,title,ndim);
%
% Example : read EAS file, and save it as an SGEMS POINTSET file
%
% [data,header,title]=read_eas('pointset.gslib');
% sgems_write_pointset('test_write.sgems',data,header,title);
%

if nargin<4
    title='DATA';
end
if nargin<5
    ndim=size(data,2);
    ndim=min([ndim-1,3]);
end
if nargin<3
    header=[];
end

O.type_def=10; % POINT SET
O.data=data(:,(ndim+1):(size(data,2)));
O.xyz=data(:,1:ndim);

O.point_set_name=title;

O.n_prop=1;

if isempty(header)
    for j=1:O.n_prop;
        h{j}=sprintf('D%03d',j);
    end
    header=h;
end
for i=1:O.n_prop
    O.P{i}.property_name=header{i+ndim};
end


O=sgems_write(filename,O);
