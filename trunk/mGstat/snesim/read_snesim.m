% read_snesim : Read SNESIM parameter file
%
function obj=read_snesim(filename) 

  if exist(filename,'file')~=2,
    help read_snesim
    obj=[];
    return
  end
  

  obj.parfile=filename;
  
  fid = fopen(filename,'r');
  
  
  % READ HEADER
  head=1;

  
  i=0;
  
  while (head==1)
      i=i+1;
      line=fgetl(fid);
      obj.header{i}=line;
      %disp(line)
      if length(line)>=19
          if (strcmp(line(1:19),'START OF PARAMETERS'))
              head=0;
          end
      end
  end
  
  
  % File with cond data 
  line=fgetl(fid);
  [fname]=get_string(line);
  obj.fconddata.fname=fname;
  try
      obj.fconddata.data=read_eas(fname);
  catch
      disp(sprintf('%s : Could not read conditional data : %s',mfilename,fname))
  end
  % Cols
  line=fgetl(fid);
  obj.fconddata.cols=sscanf(line,'%d');
  obj.fconddata.xcol=  obj.fconddata.cols(1);
  obj.fconddata.ycol=  obj.fconddata.cols(2);
  obj.fconddata.zcol=  obj.fconddata.cols(3);
  obj.fconddata.vcol=  obj.fconddata.cols(4);

  % Number for categories
  line=fgetl(fid);
  obj.ncat=sscanf(line,'%f');
  % category codes
  line=fgetl(fid);
  obj.cat_code=sscanf(line,'%f');

  % Target pdf
  line=fgetl(fid);
  obj.pdf_target=sscanf(line,'%f');

  
  % Use vertical prop
  line=fgetl(fid);
  obj.use_vert_prop=sscanf(line,'%d');
  % vertical prop file
  line=fgetl(fid);
  obj.fvertprob.fname=get_string(line);
  try
      obj.fvertprob.data=read_eas(obj.fvertprob.fname);
  end

  % Target pdf
  line=fgetl(fid);
  data=sscanf(line,'%f');
  obj.pdf_target_repro=data(1);
  obj.pdf_target_par=data(2);

  % Debug level
  line=fgetl(fid);
  obj.debug_level=sscanf(line,'%f');

  % DEBUG
  line=fgetl(fid);
  obj.fdebug.fname=get_string(line);

    % OUTPUT
  line=fgetl(fid);
  obj.out.fname=get_string(line);
  try
      obj.out.data=read_eas(obj.out.fname);
  end

  % NSIM
  line=fgetl(fid);
  obj.nsim=sscanf(line,'%f');

  % DIM INFO
  line=fgetl(fid);
  tmp=sscanf(line,'%d %f %f');
  obj.nx=tmp(1);obj.xmn=tmp(2);obj.xsiz=tmp(3);
  line=fgetl(fid);
  tmp=sscanf(line,'%d %f %f');
  obj.ny=tmp(1);obj.ymn=tmp(2);obj.ysiz=tmp(3);
  line=fgetl(fid);
  tmp=sscanf(line,'%d %f %f');
  obj.nz=tmp(1);obj.zmn=tmp(2);obj.zsiz=tmp(3);
  obj.x=[0:1:obj.nx-1]*obj.xsiz+obj.xmn;
  obj.y=[0:1:obj.ny-1]*obj.ysiz+obj.ymn;
  obj.z=[0:1:obj.nz-1]*obj.zsiz+obj.zmn;
  

  % RSEED
  line=fgetl(fid);
  obj.rseed=sscanf(line,'%f');

  % template
  line=fgetl(fid);
  obj.ftemplate.fname=get_string(line);
  try
      obj.ftemplate.data=read_eas(obj.ftemplate.fname);
  end
  
  % max cond data
  line=fgetl(fid);
  obj.max_cond=sscanf(line,'%f');
  % max data per octant
  line=fgetl(fid);
  obj.max_data_per_oct=sscanf(line,'%f');
  %  max data events
  line=fgetl(fid);
  obj.max_data_events=sscanf(line,'%f');
  
  % 
  line=fgetl(fid);
  data=sscanf(line,'%f');
  obj.n_mulgrids=data(1);
  obj.n_mulgrids_w_stree=data(2);

  % Training image
  line=fgetl(fid);
  obj.fti.fname=get_string(line);
  try
      obj.fti.data=read_eas(obj.fti.fname);
  end
  % ti dim
  line=fgetl(fid);
  data=sscanf(line,'%f');
  obj.nxtr=data(1);
  obj.nytr=data(2);
  obj.nztr=data(3);
  if obj.nztr==1
      obj.ti=reshape(obj.fti.data,obj.nxtr,obj.nytr);
  else
      obj.ti=reshape(obj.fti.data,obj.nxtr,obj.nytr,obj.nztr);
  end
  %  max data events
  line=fgetl(fid);
  obj.fti.col_var=sscanf(line,'%f');

  % Search radius
  line=fgetl(fid);
  data=sscanf(line,'%f');
  obj.hmax=data(1);
  obj.hmin=data(2);
  obj.hvert=data(3);
  % Search angles
  line=fgetl(fid);
  data=sscanf(line,'%f');
  obj.amax=data(1);
  obj.amin=data(2);
  obj.avert=data(3);
  

  nsim=obj.nsim;
  nxyz=obj.nx*obj.ny*obj.nz;
   if nsim>0
      if obj.nz==1,
        obj.D=reshape(obj.out.data(1:(nsim*nxyz)),obj.nx,obj.ny,nsim);
      else    
        obj.D=reshape(obj.out.data(1:(nsim*nxyz)),obj.nx,obj.ny,obj.nz,nsim);
      end
      if nsim==1
          E=obj.D;
          Ev=zeros(size(obj.D));
      else
         [E,Ev]=etype(obj.D);
      end
      obj.etype.mean=E;
      obj.etype.var=Ev;
      obj.nsim=nsim;
      if (nsim~=obj.nsim),
          disp(sprintf('SETTING NSIM=%d TO MATCH SIM DATA',nsim));
      end
   end

  
  
  fclose(fid);
  
  
  return
  
  
  function [str_out]=get_string(str)
  
  fspace=find(str==' ');
  if length(fspace>0)
    str_out=str(1:fspace(1)-1);
  else
    str_out=str;
  end
  
  