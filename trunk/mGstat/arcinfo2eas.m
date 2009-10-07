% arcinfo2eas : convert ArcInfo file to EAS
%
% CALL 
%    arcinfo2eas(file_arcinfo,file_eas);
%
% or  
%    arcinfo2eas(file_arcinfo);
%    using the same file name as the arcinfo file
%    but with the 'eas' file extension.
%
function arcinfo2eas(file_arcinfo,file_eas);

if nargin==1,
  [ext,file]=fileparts(file_arcinfo);
file_eas=[file,'.eas'];
end
  
  [data,x,y,dx,nanval]=read_arcinfo_ascii(file_arcinfo);
  [xx,yy]=meshgrid(x,y);
  header{1}='x';
  header{2}='y';
  header{3}='value';
  write_eas(file_eas,[xx(:) yy(:) data(:)],header);
