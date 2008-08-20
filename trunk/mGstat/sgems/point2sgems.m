% point2sgems : convert pointset data to SGeMS format
%
% Call : 
%   file_sgems=point2sgems(filename,data,header,name)
%
% Ex
%   [data,header,title]=read_eas(filename);
%   [file_sgems,file_eas]=point2sgems(filename,data,header,title);
%
% file_sgems : output SGeMS filename [filename,'.sgems'];
% 
% Uses g2s.exe (from Stanford)
%
% See also : geoeas2sgems
% 
function file_sgems=point2sgems(filename,data,header,name)

  if nargin<1,
    help(mfilename);
    return;
  end
  
  if nargin==1,
    data=filename;
    filename='dummy.sgems';;
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
  
  [p,f]=fileparts(filename);
  file_eas=[p,f,'.eas'];
  
  write_eas(file_eas,data,header,name);

  object.name=name;
  object.type=0;
  object.dim=0;
  object.keep_eas=1; % Delete EAS file when succesfully converted to SGeMS format
  file_sgems=geoeas2sgems(file_eas,object);
  