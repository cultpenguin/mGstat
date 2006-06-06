% read_visim : obj=read_visim(filename)
%
% read visim parameter file (and input/output files of they exists)
%
function obj=read_visim(filename)
  
  if exist('filename')==0,
    help read_visim
    obj=[];
    return
  end
  

  obj.parfile=filename;
  
  fid = fopen(filename,'r');
  
  
  % READ HEADER
  head=1;
  while (head==1)
    line=fgetl(fid);
    %disp(line)
    if length(line)>=19
      if (strcmp(line(1:19),'START OF PARAMETERS')) 
      head=0;
      end
    end
  end
  
  
  % COND SIM
  line=fgetl(fid);
  obj.cond_sim=sscanf(line,'%d');

  % File with cond data 
  line=fgetl(fid);
  [fname]=get_string(line);
  try
    [data,header]=read_eas(fname);
    obj.fconddata.data=data;
    obj.fconddata.header=header;
    obj.fconddata.fname=fname;
  catch
    disp(sprintf('%s : could not read %s',mfilename,fname));
  end
  % Cols
  line=fgetl(fid);
  obj.cols=sscanf(line,'%d');

  % Volume Geometry
  line=fgetl(fid);
  [fname]=get_string(line);
  try 
    [data,header]=read_eas(fname);
    obj.fvolgeom.data=data;
    obj.fvolgeom.header=header;
    obj.fvolgeom.fname=fname;
  catch
    disp(sprintf('%s : could not read %s',mfilename,fname))
  end

  % Volume Summary
  line=fgetl(fid);
  [fname]=get_string(line);
  try
    [data,header]=read_eas(fname);
    obj.fvolsum.data=data;
    obj.fvolsum.header=header;
    obj.fvolsum.fname=fname;
  catch
    disp(sprintf('%s : could not read %s',mfilename,fname))
  end

    
  line=fgetl(fid);
  obj.trimlimits=sscanf(line,'%f %f');
  line=fgetl(fid);
  obj.debuglevel=sscanf(line,'%d');

  % OUTPUT
  line=fgetl(fid);
  [fname]=get_string(line);
  try
    if exist(fname)==2,
      [data,header]=read_eas(fname);
      obj.out.data=data;
      obj.out.header=header;
      obj.out.fname=fname;
    else
      disp(['Output file : ',fname,' does not exists'])
    end
  catch
    disp(sprintf('%s  : Could not read %s',mfilename,fname))
  end
  % N SIM
  line=fgetl(fid);
  obj.nsim=sscanf(line,'%d');

  % CCDF into
  line=fgetl(fid);
  obj.ccdf=sscanf(line,'%d');
  line=fgetl(fid);
  obj.refhist.fname=get_string(line);
  line=fgetl(fid);
  tmp=sscanf(line,'%d %d');
  obj.refhist.colvar=tmp(1);
  obj.refhist.colweight=tmp(2);

  % HIST REPROD
  line=fgetl(fid);
  tmp=sscanf(line,'%f %f %d');
  obj.refhist.min_Gmean=tmp(1);
  obj.refhist.max_Gmean=tmp(2);
  obj.refhist.n_Gmean=tmp(3);
  line=fgetl(fid);
  tmp=sscanf(line,'%f %f %d');
  obj.refhist.min_Gvar=tmp(1);
  obj.refhist.max_Gvar=tmp(2);
  obj.refhist.n_Gvar=tmp(3);
  line=fgetl(fid);
  tmp=sscanf(line,'%d %d');
  obj.refhist.nq=tmp(1);
  obj.refhist.nGsim=tmp(2);
  
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
  
  
  obj.rseed=sscanf(fgetl(fid),'%d');
  tmp=sscanf(fgetl(fid),'%d %d');
  obj.minorig=tmp(1);
  obj.maxorig=tmp(2);

  % nsimdata
  line=fgetl(fid);
  obj.nsimdata=sscanf(line,'%d');

  % nvoldata
  line=fgetl(fid);
  tmp=sscanf(line,'%d %d %f');
  %obj.volmethod=tmp(1);
  %obj.voluse=tmp(2);
  obj.volnh.method=tmp(1);
  obj.volnh.max=tmp(2);
  obj.volnh.cov=tmp(3);

  % RANDPATH
  line=fgetl(fid);
  %tmp=sscanf(line,'%d %d %d');
  tmp=sscanf(line,'%d');
  obj.densitypr=tmp(1);
  %obj.shuffvol=tmp(2);
  %obj.shuffinvol=tmp(3);

  
  obj.assign_to_nodes=sscanf(fgetl(fid),'%d');
  obj.max_data_per_octant=sscanf(fgetl(fid),'%d');

  tmp=sscanf(fgetl(fid),'%f %f %f');
  obj.search_radius.hmax=tmp(1);
  obj.search_radius.hmin=tmp(1);
  obj.search_radius.vert=tmp(1);

  tmp=sscanf(fgetl(fid),'%f %f %f');
  obj.search_angle.hmax=tmp(1);
  obj.search_angle.hmin=tmp(1);
  obj.search_angle.vert=tmp(1);
  
  % global mean and var
  line=fgetl(fid);
  g=sscanf(line,'%f');
  obj.gmean=g(1);
  obj.gvar=g(2);
  

  % VARIOGRAM 
  
  % NUGGET 
  line=fgetl(fid);
  tmp=sscanf(line,'%d %f');
  obj.Va.nst=tmp(1);
  obj.Va.nugget=tmp(2);

  for ist=1:obj.Va.nst
    % VARIOGRAM 1
    line=fgetl(fid);
    format long
    tmp=sscanf(line,'%d %f %f %f %f');
    obj.Va.it(ist)=tmp(1);
    obj.Va.cc(ist)=tmp(2);
    obj.Va.ang1(ist)=tmp(3);
    obj.Va.ang2(ist)=tmp(4);
    obj.Va.ang3(ist)=tmp(5);
    
    % VARIOGRAM 2
    line=fgetl(fid);
    tmp=sscanf(line,'%f %f %f');
    obj.Va.a_hmax(ist)=tmp(1);
    obj.Va.a_hmin(ist)=tmp(2);
    obj.Va.a_vert(ist)=tmp(3);
  end
  
  line=fgetl(fid);
  tmp=sscanf(line,'%f %f');
  obj.tail.zmin=tmp(1);
  obj.tail.zmax=tmp(2);

  line=fgetl(fid);
  tmp=sscanf(line,'%f %f');
  obj.tail.lower(1)=tmp(1);
  obj.tail.lower(2)=tmp(2);

  line=fgetl(fid);
  tmp=sscanf(line,'%f %f');
  obj.tail.upper(1)=tmp(1);
  obj.tail.upper(2)=tmp(2);

  try

  
  % CREATE A MARIX OF SIM DATA :
  if isfield(obj,'out')
    
    nxyz=obj.nx*obj.ny*obj.nz;
    
    if obj.nsim>0
      if (size(obj.out.data)==nxyz*obj.nsim)
        nsim==obj.nsim;
      else
        nsim=length(obj.out.data)./(nxyz);
        nsim=floor(nsim);
      end
    else
      nsim=obj.nsim;
    end
    
    if nsim>0
      if obj.nz==1,
        obj.D=reshape(obj.out.data(1:(nsim*nxyz)),obj.nx,obj.ny,nsim);
      else    
        obj.D=reshape(obj.out.data(1:(nsim*nxyz)),obj.nx,obj.ny,obj.nz,nsim);
      end       
      [E,Ev]=etype(obj.D);

      obj.etype.mean=E;
      obj.etype.var=Ev;
            
      obj.nsim=nsim;
      if (nsim~=obj.nsim),
        disp(sprintf('SETTING NSIM=%d TO MATCH SIM DATA',nsim));
      end
    else
      [d]=read_eas(['visim_estimation_',obj.out.fname]);
      obj.etype.mean=reshape(d(:,1),obj.nx,obj.ny);
      obj.etype.var=reshape(d(:,2),obj.nx,obj.ny);
    end
  end
  
  catch
    disp('something went wrong in read_visim ...')
  end

  fclose(fid);
  
function [str_out]=get_string(str)
  
  fspace=find(str==' ');
  if length(fspace>0)
    str_out=str(1:fspace(1)-1);
  else
    str_out=str;
  end
  
