% write_snesim : obj=write_snesim(V,parfile)
%
% write snesim parameter file 
%
function write_snesim(obj,parfile)
  
  if nargin==0
    help write_snesim
    return;
  end

  
  if isstruct(obj)~=1
    disp(sprintf('%s : 1st input parameter MUST be a snesim struvture',mfilename))
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

  txt='';
  fprintf(fid,'%s                    - %s\n',obj.fconddata.fname,txt);
  fprintf(fid,'%d %d %d %d           - %s\n',obj.fconddata.xcol,obj.fconddata.ycol,obj.fconddata.zcol,obj.fconddata.vcol,txt);
  fprintf(fid,'%d                    - %s\n',obj.ncat,txt);
  fprintf(fid,'%d %d                    - %s\n',obj.cat_code(1),obj.cat_code(2),txt);
  fprintf(fid,'%g %g                    - %s\n',obj.pdf_target(1),obj.pdf_target(2),txt);
  fprintf(fid,'%d                    - %s\n',obj.use_vert_prop,txt);
  fprintf(fid,'%s                    - %s\n',obj.fvertprob.fname,txt);
  fprintf(fid,'%d %g                    - %s\n',obj.pdf_target_repro,obj.pdf_target_par,txt);
  fprintf(fid,'%d                    - %s\n',obj.debug_level,txt);
  fprintf(fid,'%s                    - %s\n',obj.fdebug.fname,txt);
  fprintf(fid,'%s                    - %s\n',obj.out.fname,txt);
  fprintf(fid,'%d                    - %s\n',obj.nsim,txt);
  fprintf(fid,'%d %g %g                   - %s\n',obj.nx,obj.xmn,obj.xsiz,txt);
  fprintf(fid,'%d %g %g                   - %s\n',obj.ny,obj.ymn,obj.ysiz,txt);
  fprintf(fid,'%d %g %g                   - %s\n',obj.nz,obj.zmn,obj.zsiz,txt);
  fprintf(fid,'%d                   - %s\n',obj.rseed,txt);
  fprintf(fid,'%s                    - %s\n',obj.ftemplate.fname,txt);
  fprintf(fid,'%d                    - %s\n',obj.max_cond,txt);
  fprintf(fid,'%d                    - %s\n',obj.max_data_per_oct,txt);
  fprintf(fid,'%d                    - %s\n',obj.max_data_events,txt);
  fprintf(fid,'%d %d                    - %s\n',obj.n_mulgrids,obj.n_mulgrids_w_stree,txt);
  fprintf(fid,'%s                    - %s\n',obj.fti.fname,txt);
  fprintf(fid,'%d %d %d                   - %s\n',obj.nxtr,obj.nytr,obj.nztr,txt);
  fprintf(fid,'%d                    - %s\n',obj.fti.col_var,txt);
  fprintf(fid,'%g %g %g                    - %s\n',obj.hmax,obj.hmin,obj.hvert,txt);
  fprintf(fid,'%g %g %g                    - %s\n',obj.amax,obj.amin,obj.avert,txt);
  
