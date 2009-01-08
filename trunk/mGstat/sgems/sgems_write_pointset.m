% sgems_write_pointset : write binary formatted SGEMS point data set
%
% Call :
%
%   O=sgems_write_pointset(filename,data,header,title,ndim);
%
%
% Example : read EAS file, and save it as an SGEMS POINTSET file
%
% [data,header,title]=read_eas('pointset.gslib');
% sgems_write_pointset('test_write.sgems',data,header,title);
%
% See also: sgems_write, sgems_write_grid, sgems_read, sgems2eas, eas2sgems
%
function O=sgems_write_pointset(filename,data,header,title,ndim);

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

O.type_def='Point_set'; % POINT SET
O.data=data(:,(ndim+1):(size(data,2)));
O.xyz=data(:,1:ndim);

O.point_set=title;

O.n_prop=1;

if isempty(header)
    h{1}='X';
    h{2}='Y';
    if ndim>2, h{3}='Z';end
    for j=1:O.n_prop;
        h{j+ndim}=sprintf('D%03d',j);
    end
    header=h;
end

for i=1:O.n_prop
    O.property_name{i}=header{i+ndim};
end


O=sgems_write(filename,O);
