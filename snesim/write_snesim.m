% write_snesim : write SNESIM V10 parameter file
%
% Ex. read/write snesim parameter file 
%   S=read_snesim('snesim.par');
%   S.nsim=10;
%   write('snesim.par',S)
%
% See also: read_snesim, snesim
% 
%function obj=write_snesim(obj,parfile);
function write_snesim(obj,parfile)
 
  if nargin==0
      
    help write_snesim
    return;
    obj=snesim_init;
  end

  
  if isstruct(obj)~=1
    disp(sprintf('%s : 1st input parameter MUST be a snesim structure',mfilename))
    return;
  end

  if nargin==2
    if isstr(parfile);
      obj.parfile=parfile;
    end
  end
  
  parfile=obj.parfile;
  
  fid = fopen(parfile,'w');
  
  % MAKE OUT FILE NAME THE SAME AS THE PARAMETER FILE + .OUT
  % [p,f]=fileparts(obj.parfile);
  % obj.out.fname=sprintf('%s.out',f);
  
  fprintf(fid,'                  Parameters for snesim\n');
  fprintf(fid,'                  ********************\n');
  fprintf(fid,'                                      \n');
  fprintf(fid,'START OF PARAMETERS                   \n');

  txt='file with original data';
  fprintf(fid,'%-30s - %s\n',obj.fconddata.fname,txt);
  
  txt='fcolumns for x, y, z, variable';
  dtxt=sprintf('%d %d %d %d',obj.fconddata.xcol,obj.fconddata.ycol,obj.fconddata.zcol,obj.fconddata.vcol);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  
  txt='number of categories';
  dtxt=sprintf('%d',obj.ncat);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  txt='category codes';
  dtxt=sprintf('%d',obj.cat_code(1));
  for i=2:obj.ncat
      dtxt=sprintf('%s %d',dtxt,obj.cat_code(i));
  end
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  txt='(target) global pdf';
  dtxt=sprintf('%g %g',obj.pdf_target(1),obj.pdf_target(2));
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  txt=' use (target) vertical proportions (0=no, 1=yes)';
  dtxt=sprintf('%d',obj.use_vert_prop);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  txt='file with target vertical proportions';
  dtxt=sprintf('%s',obj.fvertprob.fname);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  txt='servosystem parameter (0=no correction)';
  dtxt=sprintf('%d',obj.servosystem);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  txt='debugging level: 0,1,2,3';
  dtxt=sprintf('%d',obj.debug_level);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  txt='debugging file';
  dtxt=sprintf('%s',obj.fdebug.fname);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
    
  txt='file for simulation output';
  dtxt=sprintf('%s',obj.out.fname);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  txt='number of realizations to generate';
  dtxt=sprintf('%d',obj.nsim);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  txt='nx,xmn,xsiz';
  dtxt=sprintf('%d %g %g',obj.nx,obj.xmn,obj.xsiz);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  txt='ny,ymn,ysiz';
  dtxt=sprintf('%d %g %g',obj.ny,obj.ymn,obj.ysiz);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  dtxt=sprintf('%d %g %g',obj.nz,obj.zmn,obj.zsiz);
  txt='nz,zmn,zsiz';
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  txt='random number seed';
  dtxt=sprintf('%d',obj.rseed);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  
  txt='max number of conditioning primary data';
  dtxt=sprintf('%d',obj.max_cond);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  txt='min. replicates number';
  dtxt=sprintf('%d',obj.min_replicates);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  txt='condition to LP (0=no, 1=yes), flag for iauto';
  dtxt=sprintf('%d %d',obj.condition_to_lp,obj.iauto);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  txt='two weighting factors to combine P(A|B) and P(A|C)';
  dtxt=sprintf('%d %d',obj.tau1,obj.tau2);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);

  txt='file for local properties';
  dtxt=sprintf('%s',obj.flocalprob.fname);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);

  txt='condition to rotation and affinity (0=no, 1=yes)';
  dtxt=sprintf('%d',obj.frotaff.use);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  txt='file for rotation and affinity';
  dtxt=sprintf('%s',obj.frotaff.fname);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);

  
  txt='number of affinity categories';
  dtxt=sprintf('%d',obj.frotaff.n_cat);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);

  
  for i=1:obj.frotaff.n_cat
      txt=sprintf('affinity factors (X,Y,Z) icat=%d',i);
      dtxt=sprintf('%g ',obj.frotaff.aff_xyz(i,:));
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  end

  txt='number of multiple grids';
  dtxt=sprintf('%d',obj.nmulgrids);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  txt='file with training image';
  dtxt=sprintf('%s',obj.ti.fname);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);

  txt='training image dimensions: nxtr, nytr, nztr';
  dtxt=sprintf('%d %d %g',obj.ti.nx,obj.ti.ny,obj.ti.nz);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  
  txt='column for training variable';
  dtxt=sprintf('%d',obj.ti.col_var);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  
  txt='maximum search radii (hmax,hmin,hvert)';
  dtxt=sprintf('%g %g %g',obj.search_radius.hmax,obj.search_radius.hmin,obj.search_radius.hvert);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  txt='angles for search ellipsoid (amax,amin,avert)';
  dtxt=sprintf('%g %g %g',obj.search_radius.amax,obj.search_radius.amin,obj.search_radius.avert);
  fprintf(fid,'%-30s - %s\n',dtxt,txt);
  
  

fclose(fid);


return

