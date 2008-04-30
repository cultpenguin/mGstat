% write_surfer_grid : Writes ascii formatted Surfer GRD file
% 
% CALL :
% [data,x,y,dx,nanval]=write_surfer_grid(filename,data,x,y);
%
% filename [char] :string
% data [ny,nx]
% x [nx]
% y [ny]

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

function [data,x,y,dx,nanval]=write_surfer_grid(filename,data,x,y);
  mgstat_verbose(sprintf('Calling %s with %d arguments',mfilename,nargin),2);
  
  if nargin<2,
    help(mfilename)
    return
  end

  NCOLS=size(data,2);
  NROWS=size(data,1);
      
  if nargin<3, x=[1:1:NCOLS]; end
  if nargin<4  y=[1:1:NROWS]; end
  if nargin<5, nannumber=[]; end
  if nargin<6, xll='CENTER'; end
  if nargin<7, yll=xll; end
  
  
  % CHECK FOR CONSISTENCY BETWEEN data AND (x,y)
  if (length(y)~=NROWS)
    mgstat_verbose(sprintf('!!! NROWS=%d ~= NY=%d',NROWS,length(y)),-1)
  end  
  
  if (length(x)~=NCOLS)
    mgstat_verbose(sprintf('!!! NCOLS=%d ~= NX=%d',NCOLS,length(x)),-1)
  end
  
  fid=fopen(filename,'w');

 
  fprintf(fid,'%s\n','DSAA');
  
  fprintf(fid,'%d %d\n',NCOLS,NROWS);
  fprintf(fid,'%g %g\n',min(x),max(x));
  fprintf(fid,'%g %g\n',min(y),max(y));
  fprintf(fid,'%g %g\n',min(data(:)),max(data(:)));

  for iy=1:length(y)
    fprintf(fid,' %d',data(iy,:));
    fprintf(fid,'\n');
  end
  fclose(fid);
  