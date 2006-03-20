function o=fast_fd_write_par(sx,sz,o);

  f_fin='f.in';
  f_forheader='for.header';

  if nargin<1
    sx=linspace(10,20,10);
  end
  nshots=length(sx);
  sy=sx.*0;
  if nargin<2, sz=linspace(1,30,nshots); end;

  
  o.iwrite=0; o.iout=1; o.itimes=-1;
  
  o.i2d=1; o.istop=0; o.nreverse=0; o.reverse=2;
  if ~isfield(o,'tmax'), o.tmax=200;  end
  
  o.inear=0; o.vabove=4.0; o.vbelow=4.0;
  
  % WRITE f.in
  f1=fopen(f_fin,'w');
  
  fprintf(f1,'  &pltpar\n');
  fprintf(f1,'    iwrite=%d, iout=%d, itimes=%d,\n',o.iwrite,o.iout,o.itimes);
  fprintf(f1,'  &end\n');
  
  fprintf(f1,'  &axepar\n');
  fprintf(f1,'  &end\n');
  
  fprintf(f1,'  &propar\n');
  fprintf(f1,'    i2d=%d, istop=%d, tmax=%d, nreverse=%d, reverse=%d, \n',o.i2d,o.istop,o.tmax,o.nreverse,o.reverse);
  fprintf(f1,'  &end\n');
  
  fprintf(f1,'  &srcpar\n');
  fprintf(f1,'     inear=%d, vabove=%3.1f, vbelow=%3.1f,\n',o.inear,o.vabove,o.vbelow);
  fprintf(f1,'     isource=%d*1,\n',nshots);
  sx_string=sprintf('%5.2f,',sx);
  fprintf(f1,'     xsource=%s\n',sx_string);
  sy_string=sprintf('%5.2f,',sy);
  fprintf(f1,'     ysource=%s\n',sy_string);
  sz_string=sprintf('%5.2f,',sz);
  fprintf(f1,'     zsource=%s\n',sz_string);
  fprintf(f1,'  &end\n');
  
  fclose(f1);
  
  
  % WRITE for.in
  if ~isfield(o,'xmin');o.xmin=0;end
  if ~isfield(o,'xmax');o.xmax=80;end
  if ~isfield(o,'ymin');o.ymin=0;end
  if ~isfield(o,'ymax');o.ymax=0;end
  if ~isfield(o,'zmin');o.zmin=0;end
  if ~isfield(o,'zmax');o.zmax=40;end
  if ~isfield(o,'dx');o.dx=0.5;end
  if ~isfield(o,'nx');o.nx=161;end
  if ~isfield(o,'ny');o.ny=1;end
  if ~isfield(o,'nz');o.nz=81;end
  
  f2=fopen(f_forheader,'w');
  fprintf(f2,'%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10d%10d%10d\n',o.xmin,o.xmax,o.ymin,o.ymax,o.zmin,o.zmax,o.dx,o.nx,o.ny,o.nz);
  fclose(f2);
  
  
  f3=fopen('nowrite','w');
  fprintf(f3,' ');
  fclose(f3);
  
