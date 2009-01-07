% sgems2eas : convert SGEMS binary file to eas ASCII file
%
%   [data,header,title]=sgems2eas(file_sgems,file_eas);
%
% Note, if the sgems binary file contains Grid data, the origing
% (x0,y0,z0), and cell size information (dx,dy,dz) is lost;
%
% Examples:
%
% Convert 'file.sgems' til 'anyname.eas'
%   eas2sgems('file.sgems','anyname.eas')
% Convert 'file.sgems' til 'file.eas'
%   eas2sgems('file.sgems');
% Convert 'file.sgems' til 'file.eas', and read 'file.eas'
%   [data,header,title]=eas2sgems('file.sgems');
%
%


function [data,header,title]=sgems2eas(file_sgems,file_eas);

if nargin<2
    [p,f,e]=fileparts(file_sgems);
    if isempty(p); p=pwd;end
    file_eas=[p,filesep,f,'_test','.eas'];
end

O=sgems_read(file_sgems);

if strcmp(O.type_def,'Cgrid')
    tit=sprintf('%s (%dx%dx%d)',O.grid_name,O.nx,O.ny,O.nz);
    write_eas(file_eas,O.data,O.property,tit);
elseif strcmp(O.type_def,'Point_set');
    for i=1:size(O.xyz,2)
        property{i}=char(87+i);
    end
    for j=1:length(O.property_name);
        property{i+j}=O.property_name{j};
    end
    
    write_eas(file_eas,[O.xyz,O.data],property,O.point_set);
else
    mgstat_verbose(sprintf('%s : Format of %s not recognized',mfilename,file_sgems),10);
end

if nargout>0
    [data,header,title]=read_eas(file_eas);
end


