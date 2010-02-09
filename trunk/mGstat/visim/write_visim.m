% write_visim : obj=write_visim(V,parfile)
%
% write visim parameter file
%
function V=write_visim(obj,parfile)

if nargin==0
    help write_visim
    return;
end


if isstruct(obj)~=1
    disp(sprintf('%s : 1st input parameter MUST be a VISIM struvture',mfilename))
    return;
end

if nargin==2
    if isstr(parfile);
        obj.parfile=parfile;
    end
end

if ~isfield(obj.refhist,'do_discrete')
    obj.refhist.do_discrete=0;
end

if ~isfield(obj,'do_cholesky')
    obj.do_cholesky=0;
end
if ~isfield(obj,'do_error_sim')
    obj.do_error_sim=0;
end

parfile=obj.parfile;
[par_path,par_file]=fileparts(parfile);

fid = fopen(parfile,'w');

% MAKE OUT FILE NAME THE SAME AS THE PARAMETER FILE + .OUT
[p,f]=fileparts(obj.parfile);
obj.out.fname=sprintf('%s.out',f);

fprintf(fid,'                  Parameters for VISIM\n');
fprintf(fid,'                  ********************\n');
fprintf(fid,'                                      \n');
fprintf(fid,'START OF PARAMETERS                   \n');

fprintf(fid,'%d                    # - conditional simulation (3=Vol,2=point,1=Vol+Point, 0=Uncon)\n',obj.cond_sim);
if (~isfield(obj,'fconddata'))
    obj.fconddata.fname='nodata';
end
fprintf(fid,'%s # - file with conditioning data\n',obj.fconddata.fname);

%  fprintf(fid,'%d %d %d %d %d %d       # -  columns1 for X,Y,Z,vr,wt,sec.var\n',obj.cols(1),obj.cols(2),obj.cols(3),obj.cols(4),obj.cols(5),obj.cols(6));
fprintf(fid,'%d %d %d %d       # -  columns1 for X,Y,Z,vr,wt,sec.var\n',obj.cols(1),obj.cols(2),obj.cols(3),obj.cols(4));
if (~isfield(obj,'fvolgeom'))
    obj.fvolgeom.fname='dummy';
end
fprintf(fid,'%s      # -  Geometry of volume/ray\n',obj.fvolgeom.fname);
if (~isfield(obj,'fvolsum'))
    obj.fvolsum.fname='dummy';
end
fprintf(fid,'%s      # -  Summary of volgeom.eas\n',obj.fvolsum.fname);
fprintf(fid,'%8.3g %8.3g       # -  trimming limits for conditioning data\n',obj.trimlimits(1),obj.trimlimits(2));
if isfield(obj,'read_covtable')==0, obj.read_covtable=-1; end
if isfield(obj,'read_lambda')==0, obj.read_lambda=-1; end
if isfield(obj,'read_volnh')==0, obj.read_volnh=-1; end
if isfield(obj,'read_randpath')==0, obj.read_randpath=-1; end
fprintf(fid,['%d  %d %d %d %d  %d %d            # - debugging level: -1,0,1,2,3, ' ...
    'read_covtable,read_lambda,read_volnh,read_randpath,do_cholesky,do_error_sim\n'],obj.debuglevel,obj.read_covtable,obj.read_lambda,obj.read_volnh,obj.read_randpath,obj.do_cholesky,obj.do_error_sim);
fprintf(fid,'%s                    # - file for output\n',obj.out.fname);

fprintf(fid,'%d                     # - number of realizations to generate\n',obj.nsim);
fprintf(fid,'%d                       # - ccdf. type: 0-normal, 1-target \n',obj.ccdf);
fprintf(fid,'%s                    # - target histogram file\n',obj.refhist.fname);

fprintf(fid,'%d %d                     # - columns for variable and weights\n',obj.refhist.colvar,obj.refhist.colweight);
fprintf(fid,'%5.2f %5.2f %d         # - min_Gmean, max_Gmean, n_Gmean\n',obj.refhist.min_Gmean,obj.refhist.max_Gmean,obj.refhist.n_Gmean);
fprintf(fid,'%5.2f %5.2f %d         # - min_Gvar, max_Gvar, n_Gvar\n',obj.refhist.min_Gvar,obj.refhist.max_Gvar,obj.refhist.n_Gvar);
fprintf(fid,'%d %d               # - nq, do_discrete \n',obj.refhist.nq,obj.refhist.do_discrete);
fprintf(fid,'%3d %8.4f %8.4f   # - nx,xmn,xsiz\n',obj.nx,obj.xmn,obj.xsiz);
fprintf(fid,'%3d %8.4f %8.4f   # - ny,ymn,ysiz\n',obj.ny,obj.ymn,obj.ysiz);
fprintf(fid,'%3d %8.4f %8.4f   # - nz,zmn,zsiz\n',obj.nz,obj.zmn,obj.zsiz);
fprintf(fid,'%d                   # - random number seed\n',obj.rseed);


fprintf(fid,'%d %d                     # - min and max original data for sim\n',obj.minorig,obj.maxorig);
fprintf(fid,'%d                      # - number of simulated nodes to use\n',obj.nsimdata);
fprintf(fid,'%d %3d %8.3f          # - volNH method(0,1,2) nusevols, covlevel \n',obj.volnh.method,obj.volnh.max,obj.volnh.cov);

% NEW NAME
fprintf(fid,'%d                       # - Random path \n',obj.densitypr);
fprintf(fid,'%d                       # - assign data to nodes (0=no, 1=yes)\n',obj.assign_to_nodes);
fprintf(fid,'%d                       # - maximum data per octant (0=not used)\n',obj.max_data_per_octant);

fprintf(fid,'%9.4f %9.4f %9.4f   # - radius for search ellipsoid\n',obj.search_radius.hmax,obj.search_radius.hmin,obj.search_radius.vert);
fprintf(fid,'%9.4f %9.4f %9.4f   # - angles for search ellipsoid\n',obj.search_angle.hmax,obj.search_angle.hmin,obj.search_angle.vert);
fprintf(fid,'%16.10f %16.10f             # - global mean and variance \n',obj.gmean,obj.gvar);
fprintf(fid,'%d %19.9f             # - nst, nugget effect\n',obj.Va.nst,obj.Va.nugget);
for in=1:obj.Va.nst;
    fprintf(fid,'%d %19.9f %10.6f %9.4f %9.4f # - it,cc,ang1,ang2,ang3\n',obj.Va.it(in),obj.Va.cc(in),obj.Va.ang1(in),obj.Va.ang2(in),obj.Va.ang3(in));
    fprintf(fid,'%9.4f %9.4f %9.4f             # - a_hmax, a_hmin, a_vert\n',obj.Va.a_hmax(in), obj.Va.a_hmin(in), obj.Va.a_vert(in));
end
fprintf(fid,'%5.3f %5.3f             # - zmin,zmax (tail extrapolation for target histogram)\n',obj.tail.zmin,obj.tail.zmax);
fprintf(fid,'%d %5.3f                 # - lower tail option, parameter\n',obj.tail.lower);
fprintf(fid,'%d %5.3f                 # - upper tail option, parameter\n',obj.tail.upper);

fclose(fid);

% WRITE MASK IF IT EXISTS
if isfield(obj,'mask');
    
    f_mask=sprintf('mask_%s.out',par_file);
    if isfield(obj.mask,'enable')
        if obj.mask.enable==0
            delete(f_mask);
        end
    end
    
    try
        if (isfield(obj.mask,'write'));
            if obj.mask.write==1;
                m=obj.mask.mask';
                write_eas(f_mask,m(:));
            end
        end
    end
end

if nargout==1;
    V=read_visim(parfile);
end


