%write_bin.m 
%
% CALL : 
%   write_bin(filename,variable,fchar,format,b_order);
%
% REQUIRED : 
%   filename (string)
%   variable : to be written to a binary file;
%
% OPTIONAL
%   fchar (scalar)  : [1] Remove F77 chracters [0,defailt] do nothing
%   format (string) : 'float32' [default] or 'int16' or 'int32',...
%   b_order : set byteorder : '0' : Little Endian 

%
% TMH/2006
function write_bin(filename,variable,fchar,format,b_order);

if nargin<2;
  disp('This function needs a filename and a variable')
  help write_bin
  return
end

if nargin<3;
  fchar=0;
end

if nargin<4;
  format='float32';
end

if nargin==5;
  if exist('b_order')
    if b_order==0, b_order='ieee-le'; end
    if b_order==1, b_order='ieee-be'; end
  end
  fid=fopen(filename,'w',b_order);
else
   fid=fopen(filename,'w');
end

[nx,nz]=size(variable);

if fchar==1
  
  for k=1:nx
    fwrite(fid,2*nz,'int32');
    fwrite(fid,variable(k,:),format);
    fwrite(fid,2*nz,'int32');
  end
else
  fwrite(fid,variable(:),format);
end

fclose(fid);
