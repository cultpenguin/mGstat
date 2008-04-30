% read_surfer_grid : Read Surfer ASCII GRD file
%
% CALL :
% [data,x,y]=read_surfer_grid(filename);
%
% IN:
%   filename [char] :string
% OUT:
%   data [ny,nx]
%   x [nx]
%   y [ny]
%

%
% Copyright (C) 2008 Thomas Mejer Hansen
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
%


function [data,x,y]=read_surfer_grid(filename);

fid=fopen(filename,'r');

TYPEID=sscanf(fgetl(fid),'%s');
if ~strcmp(TYPEID,'DSAA')
    sprintf('%s : This does not look like a Surfer GRD file (no DSAA in first line')
end

[d]=sscanf(fgetl(fid),'%d %d');
NCOLS=d(1);NROWS=d(2);

[d]=sscanf(fgetl(fid),'%g %g');
xmin=d(1);xmax=d(2);

[d]=sscanf(fgetl(fid),'%g %g');
ymin=d(1);ymax=d(2);

[d]=sscanf(fgetl(fid),'%g %g');
dmax=d(1);dmax=d(2);

x=linspace(xmin,xmax,NCOLS);
y=linspace(ymin,ymax,NROWS);

data=fscanf(fid,'%g');
data=reshape(data,NCOLS,NROWS);

