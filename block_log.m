% block_log : block a log
%
% Call:
%   [mz,z_out]=block_log(val,z,bz);
%
function [mz,z_out]=block_log(val,z,bz);

if nargin==1
  z=1:1:length(val);
  bz=10;
end

if nargin==2
  bz=(z(2)-z(1))*10;
end

nz=length(z);
dz=z(2)-z(1);
nbz=round(bz./dz);

disp(sprintf('%s : Block average over %d cells',mfilename,nbz));

z1=ceil(nbz/2)+1;
z2=nz-ceil(nbz/2);
blockz=[z1:nbz:z2];

for i=1:length(blockz);
  iz1=blockz(i)-ceil(nbz/2);
  iz2=iz1+nbz-1;
  mz(i)=mean(val(iz1:iz2));
end
  
  mz=mz(:);

z_out=z(blockz);
