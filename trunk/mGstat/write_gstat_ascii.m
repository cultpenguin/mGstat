function [data,x,y,dx,nanval]=write_gstat_ascii(filename,data,x,y,nannumber);
  
  fid=fopen(filename,'w');
  
  NCOLS=size(data,2);
  NROWS=size(data,1);
  XLLCORNER=x(1);
  YLLCORNER=y(1);
  if length(x)>1
    CELLSIZE=x(2)-x(1);
  else
    CELLSIZE=y(2)-y(1);
  end
  NODATA_VALUE=nannumber;

  data(find(isnan(data)))=NODATA_VALUE;
  
  fprintf(fid,'%s %d\n','NCOLS',NCOLS);
  fprintf(fid,'%s %d\n','NROWS',NROWS);
  fprintf(fid,'%s %d\n','XLLCENTER',XLLCORNER);
  fprintf(fid,'%s %d\n','YLLCENTER',YLLCORNER);
  fprintf(fid,'%s %d\n','CELLSIZE',CELLSIZE);
  fprintf(fid,'%s %d\n','NODATA_VALUE',NODATA_VALUE);
  for iy=1:length(y)
    fprintf(fid,' %d',data(iy,:));
    fprintf(fid,'\n');
  end
  fclose(fid);
  