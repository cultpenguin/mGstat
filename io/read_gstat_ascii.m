function [data,x,y,dx,nanval]=read_gstat_ascii(filename);
  fid=fopen(filename,'r');

  l=fgetl(fid);
  nc=str2num(l(10:length(l)));

  l=fgetl(fid);
  nr=str2num(l(10:length(l)));
  
  l=fgetl(fid);
  x0=str2num(l(10:length(l)));
  l=fgetl(fid);
  y0=str2num(l(10:length(l)));
  l=fgetl(fid);
  dx=str2num(l(10:length(l)));

  l=fgetl(fid);
  nanval=str2num(l(14:length(l)));
  
  x=[0:1:(nc-1)].*dx+x0;  
  y=[0:1:(nr-1)].*dx+y0;  
  
  % now read the data
  d=fread(fid,'char');
  data=flipud(str2num(setstr(d)'));
  
  data(find(data==nanval))=NaN;
  
  
  
  fclose(fid);