function data=read_gstat_semivar(file)
  
  fid = fopen(file);
  
  for i=1:8
    fgetl(fid);
  end
  
  d=fscanf(fid,'%g');
  data=reshape(d,5,length(d)/5)';
  fclose(fid);
  