% write_arcinfo_ascii : Writes ascii formatted ArcInfo files
% 
% CALL :
% [data,x,y,dx,nanval]=write_arcinfo_ascii(filename,data,x,y,nannumber,xll,yll);
%
% filename [char] :string
% data [ny,nx]
% x [nx]
% y [ny]
% nannumber [1] : can be left empty []. Optional.
% xll [char] : 'CENTER'(def) or 'CORNER'. Optional.
% yll [char] : 'CENTER' or 'CORNER'. if 'xll' is set, yll=xll.

%
% Copyright (C) 2004 Thomas Mejer Hansen
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

function [data,x,y,dx,nanval]=write_arcinfo_ascii(filename,data,x,y,nannumber,xll,yll);

  mgstat_verbose(sprintf('Calling %s with %d arguments',mfilename,nargin),2);
  
  if nargin<2,
    help write_arcinfo_ascii
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

  
  XLLVAL=x(1);
  YLLVAL=y(1);
  if length(x)>1
    CELLSIZE=x(2)-x(1);
  else
    CELLSIZE=y(2)-y(1);
  end
  NODATA_VALUE=nannumber;

  data(find(isnan(data)))=NODATA_VALUE;
  
  fid=fopen(filename,'w');

  fprintf(fid,'%s %d\n','NCOLS',NCOLS);
  fprintf(fid,'%s %d\n','NROWS',NROWS);
  if strcmp(upper(xll),'CORNER')
    fprintf(fid,'%s %d\n','XLLCORNER',XLLVAL);
  else 
    fprintf(fid,'%s %d\n','XLLCENTER',XLLVAL);
  end
  if strcmp(upper(yll),'CORNER')
    fprintf(fid,'%s %d\n','YLLCORNER',YLLVAL);
  else 
    fprintf(fid,'%s %d\n','YLLCENTER',YLLVAL);
  end

  fprintf(fid,'%s %d\n','CELLSIZE',CELLSIZE);
  if (~isnan(NODATA_VALUE))
    fprintf(fid,'%s %d\n','NODATA_VALUE',NODATA_VALUE);
  end
  for iy=1:length(y)
    fprintf(fid,' %d',data(iy,:));
    fprintf(fid,'\n');
  end
  fclose(fid);
  