% point2sgems : convert pointset data to SGeMS format
%
% Uses g2s.exe (from Stanford)
%
% See also : geoeas2sgems
% 
function file_sgems=point2sgems(filename,data,header,name)

  if nargin<1,
    help write_eas;
    return;
  end
  
  if nargin==1,
    data=filename;
    filename='dummy.eas';;
    mgstat_verbose(sprintf('%s : Filename not set, using ''%s''.',mfilename,filename),0)
  end
 
  if nargin<3,
    for i=1:size(data,2);
      header{i}=sprintf('col%d, unknown',i);
    end
  end
  
  if nargin<4,
      name=space2char(sprintf('Data written by mGstat %s',date));
  end
  
  write_eas(filename,data,header,name);

  object_name=name;
  object_type=0;
  object_dim=0;
  file_sgems=geoeas2sgems(filename,object_name,object_type,object_dim);
  