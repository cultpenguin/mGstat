% read_bin : Reads a binary file to matlab
%
% CALL : function [dataout]=read_bin(fileid,nx,nz,fchar,b_order)
%
% REQUIRED
%   fileid
%   nx
%
% OPTIONAL
%   nz      : Number of samples in 2nd direction
%   fchar (scalar)  : (==1)Remove F77 chracters
%   b_order : set byteorder : '0' : Little Endian 
%                             '1' : Big endian 
%
%
% /TMH FEB 09 1999
%
function [dataout]=read_bin(fileid,nx,nz,fchar,b_order)

if nargin<1;
  disp('This function needs a fileid')
  help read_bin
  return
end

if nargin==1;
  nx=1;
  nz=0;
  fchar=0;
end
if nargin==2;
  nz=0;
  fchar=0;
end

if nargin==3;
  fchar=0;
end

if fchar==1;
  nx=nx+2;
end

if exist('b_order')
  if b_order==0, b_order='ieee-le'; end
  if b_order==1, b_order='ieee-be'; end
end




% 
% if bye-order is set -> use it
%  
if exist('b_order')==1,
  fid=fopen(fileid,'r',b_order);
else
  fid=fopen(fileid,'r');
end

if nz==0,
  [data,ndata]=fread(fid,'float32');
   fclose(fid);
   app_nz=floor(ndata/nx);
   nz=app_nz; 
  % disp(['read_bin : Using nz=',num2str(nz)])
else
   [data,ndata]=fread(fid,nz*nx,'float32');
   fclose(fid);
end

app_nz=floor(ndata/nx);

% if nz input is to big for read data
%
%if nz>app_nz
%  disp(['read_bin : nz=',num2str(nz),' is too high. Using nz=',num2str(app_nz)])
%  nz=app_nz;
%end

dataout=reshape(data(1:nx*nz),nx,nz);

% Remove f77 characters
%
if fchar==1,
  dataout=dataout(2:nx-1,1:nz);
end

