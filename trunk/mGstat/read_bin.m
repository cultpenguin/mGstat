% read_bin : Reads a binary file to matlab
%
% CALL : function [dataout]=read_bin(fileid,nx,nz,fchar,format,b_order)
%
% REQUIRED
%   fileid
%   nx
%
% OPTIONAL
%   nz      : Number of samples in 2nd direction
%   fchar (scalar)  : (==1)Remove F77 chracters
%   format (string) : 'float32' [default] or 'int16' or 'int32',...
%   b_order : set byteorder : '0' : Little Endian 
%                             '1' : Big endian 
%
%
% /TMH 2006
%
function [dataout]=read_bin(fileid,nx,nz,fchar,format,b_order)

if nargin<1;
  disp('This function needs a filename')
  help read_bin
  return
end

if nargin<2;
  nx=1;
  nz=0;
end

if nargin<3;
  nz=0;
end

if nargin<4;
  fchar=0;
end


if nargin<5;
  format='float32';
end

if nargin<6;
  b_order=0;
end

if exist('b_order')
  if b_order==0, b_order='ieee-le'; end
  if b_order==1, b_order='ieee-be'; end
end


if ~isempty(strfind(format,'8')),    
  nps=1;
elseif ~isempty(strfind(format,'16')),
  nps=2;
else
  nps=4;
end 
nfbyte=4./nps;


% 
% if bye-order is set -> use it
%  
if exist('b_order')==1,
  fid=fopen(fileid,'r',b_order);
else
  fid=fopen(fileid,'r');
end

% GET NZ
if nz==0;
  fseek(fid,0,'eof');
  n=ftell(fid);
  fseek(fid,0,'bof');
  if fchar==1,
    nz=n/(nx+2*nfbyte)/nbps;
  else
    nz=n/(nx)/nps;    
  end
end

if fchar==1 
  nx_fortran=(nx+2*nfbyte);
  [dataout,ndata]=fread(fid,nz*nx_fortran,format);
  fclose(fid);
  dataout=reshape(dataout,nx_fortran,nz);
  dataout=dataout([1:nx]+(nfbyte),:)';  
else  
  [dataout,ndata]=fread(fid,nz*nx,format);

  dataout=reshape(dataout,nx,nz)';
  fclose(fid);
end
