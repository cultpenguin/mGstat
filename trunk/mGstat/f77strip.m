% f77strip : Strips f77 characters from binary file.
%
% [data]=f77strip(file,format,xskip,zskip);
%
% IN :
% required
% file [string], optional, deafult='f77.bin'
%
% optional :
% format [string], 'float16','float32'[default],'float64'
% xskip [scalar], Skip every xskip column
% zskip [scalar], Skip every zskip row
%
% OUT
% data [matrix], required
%
% Purpose : Reads a f77 style binary file
%
% At the beginning and end of each row, an integer
% containing the number of bytes in the row is printed
% (like ftnunstrip/ftnstrip in the CWP SU package)
%
% by Thomas Mejer Hansen, 05/2000
% Octave 2.0.15 and Matlab 5.3 compliant
%
function data=f77strip(file,format,xskip,zskip);

if nargin==0, help wrtf77; return; end

if nargin==1,
  xskip=1;
  zskip=1;
  format='float32';
end
if nargin==2,
  xskip=1;
  zskip=1;  
end
if nargin==3,
  zskip=xskip;
end

if ~isempty(strfind(format,'8')),    
  bsize=1;
elseif ~isempty(strfind(format,'16')),
  bsize=2;
elseif ~isempty(strfind(format,'32')),
  bsize=4;
else
  bsize=8;
end 

fid=fopen(file,'r');
nx=fread(fid,1,'int32')/bsize;
disp([' f77strip : nx=',num2str(nx)])  

info = dir(file);
filesize = info.bytes/bsize;
% NOT CORRECT --.
nz=filesize/(nx+2);
disp([' f77strip : nz=',num2str(nz)])

%  [mat,nxbytes]=fread(fid,inf,'int32');
%  
%  disp([' f77strip : nx=',num2str(nx),' nz=',num2str(nz)])
%fclose(fid);

smallnx=floor(nx/xskip);
smallnz=floor(nz/zskip);
data=zeros(smallnz,smallnx);
if nargin~=1,
  disp([' f77strip : output size : nx=',num2str(smallnx),' nz=',num2str(smallnz)])
end


fid=fopen(file,'r');
  for iz=1:smallnz
    fch=fread(fid,1,'int32');
    d=fread(fid,nx,format);
%    keyboard
    dd=d(xskip:xskip:nx);
    data(iz,:)=dd';
    fread(fid,1,'int32');
  
    % SKIP TRACES
    for i=1:(zskip-1)
      fread(fid,1,'int32');
      fread(fid,nx,format);
      fread(fid,1,'int32');
    end
  end
  fclose(fid);



