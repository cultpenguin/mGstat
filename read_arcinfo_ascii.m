% read_arcinfo_ascii : Reads ascii formatted ArcInfo files
%  
% Call : 
%   [data,x,y,dx,nanval,x0,y0,xll,yll]=read_arcinfo_ascii(filename);
%

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
function [data,x,y,dx,nanval,x0,y0,xll,yll]=read_arcinfo_ascii(filename);
  mfilename='';

  mgstat_verbose(sprintf('Calling %s, file %s',mfilename,filename),2);
  

  fid=fopen(filename,'r');

  % NCOLS 
  l=fgetl(fid);
  nc=str2num(l(7:length(l)));
  mgstat_verbose(sprintf('%s : NCOLS=%4.2d',l(1:5),nc),10);
  
  % NROWS
  l=fgetl(fid);
  nr=str2num(l(7:length(l)));
  mgstat_verbose(sprintf('%s : NROWS=%4.2d',l(1:5),nr),10);
  
  % XLLCENTER/XLLCORNER
  l=fgetl(fid);
  if (strcmp(upper(l(4:9)),'CORNER'));
    xll='CORNER';
  else
    xll='CENTER';
  end
  x0=str2num(l(11:length(l)));
  mgstat_verbose(sprintf('XLL%s=%4.2g',xll,x0),10);
  
  % YLLCENTER/YLL/CORNER
  l=fgetl(fid);
  if (strcmp(upper(l(4:9)),'CORNER'));
    yll='CORNER';
  else
    yll='CENTER';
  end
  y0=str2num(l(11:length(l)));
  mgstat_verbose(sprintf('YLL%s=%8.4g',yll,y0),10);
  
  % CELLSIZE
  l=fgetl(fid);
  dx=str2num(l(10:length(l)));
  mgstat_verbose(sprintf('%s : DX=%8.4g',l(1:8),dx),10);
  
  
  % NO DATA VALUE
  fpos=ftell(fid); % GET POSITION IN FILE
  l=fgetl(fid);

  if (strcmp(upper(l(1:12)),'NODATA_VALUE'))
    nanval=str2num(l(14:length(l)));
    mgstat_verbose(sprintf('%s : NANVALUE=%8.4g',l(1:12),nanval),10);
  else
    nanval=[];
    fseek(fid,0,'bof');
    fseek(fid,fpos,'bof'); % RETURN TO 'FPOS' (START OF LINE)
  end

  
  % CALCULATE X AND Y
  if strcmp(xll,'CENTER');
    x=[0:1:(nc-1)].*dx+x0;  
    mgstat_verbose(sprintf('X : AT CENTER'),10);
  else
    x=[0:1:(nc-1)].*dx+x0+dx/2;  
    mgstat_verbose(sprintf('X : AT CORNER'),10);        
  end
  
  if strcmp(yll,'CENTER');
    y=[0:1:(nr-1)].*dx+y0;  
    mgstat_verbose(sprintf('Y : AT CENTER'),10);
  else
    y=[0:1:(nr-1)].*dx+y0+dx/2;   
    mgstat_verbose(sprintf('Y : AT CORNER'),10);        
  end
  
  % now read the data
  d=fread(fid,'char');
  data=flipud(str2num(setstr(d)'));
  
  if ~isempty(nanval)
    data(find(data==nanval))=NaN;
  end
  
  
  
  fclose(fid);
