% read_visim : obj=read_visim(filename)
%
% read visim parameter file (and input/output files of they exists)
%
function obj=read_visim(filename)

if nargin==0;
    filename='visim.par';
end

if exist(filename,'file')~=2,
    help read_visim
    obj=[];
    return
end

obj.parfile=filename;
[par_path,par_file]=fileparts(filename);

fid = fopen(filename,'r');
UNEST=-9999999.0;

% READ HEADER
head=1;
j=0;
while (head==1)
    j=j+1;
    line=fgetl(fid);
    %disp(line)
    if length(line)>=19
        if (strcmp(line(1:19),'START OF PARAMETERS'))
            head=0;
        end
    end
    if j==10;
        mgstat_verbose(sprintf('%s : problem dealing with %s - exiting',mfilename,file));
        return;
    end
end


% COND SIM
line=fgetl(fid);
obj.cond_sim=sscanf(line,'%d');

% File with cond data
line=fgetl(fid);
[fname]=get_string(line);
if ((obj.cond_sim==1)|(obj.cond_sim==2))
    if (~strcmp('dummy',fname))
        try
            [data,header]=read_eas(fname);
            obj.fconddata.data=data;
            obj.fconddata.header=header;
            obj.fconddata.fname=fname;
        catch
            disp(sprintf('%s : could not read %s',mfilename,fname));
        end
    end
end
% Cols
line=fgetl(fid);
obj.cols=sscanf(line,'%d');

% Volume Geometry
line=fgetl(fid);
[fname]=get_string(line);
if (~strcmp('dummy',fname))
    try
        [data,header]=read_eas(fname);
        obj.fvolgeom.data=data;
        obj.fvolgeom.header=header;
        obj.fvolgeom.fname=fname;
    catch
        disp(sprintf('%s : could not read %s',mfilename,fname))
    end
end

% Volume Summary
line=fgetl(fid);
[fname]=get_string(line);
if (~strcmp('dummy',fname))
    try
        [data,header]=read_eas(fname);
        obj.fvolsum.data=data;
        obj.fvolsum.header=header;
        obj.fvolsum.fname=fname;
    catch
        disp(sprintf('%s : could not read %s',mfilename,fname))
    end
end

line=fgetl(fid);
obj.trimlimits=sscanf(line,'%f %f');
line=fgetl(fid);
tmp=sscanf(line,'%d %d %d %d %d');

try
    obj.read_covtable=tmp(2);
catch
    obj.read_covtable=-1;
end
try
    obj.read_lambda=tmp(3);
catch
    obj.read_lambda=-1;
end
try
    obj.read_volnh=tmp(4);
catch
    obj.read_volnh=-1;
end
try
    obj.read_randpath=tmp(5);
catch
    obj.read_randpath=-1;
end
try
    obj.do_cholesky=tmp(6);
catch
    obj.do_cholesky=0;
end
try
    obj.do_error_sim=tmp(7);
catch
    obj.do_error_sim=0;
end

%   if length(tmp)==1
%       obj.read_covtable=0;
%       obj.read_lambda=0;
%   elseif length(tmp)==2
%       obj.read_lambda=0;
%       obj.read_covtable=tmp(2);
%   else
%       obj.read_covtable=tmp(2);
%       obj.read_lambda=tmp(3);
%   end
obj.debuglevel=tmp(1);
%obj.debuglevel=sscanf(line,'%d %d');


% OUTPUT
line=fgetl(fid);
[fname]=get_string(line);
try
    if exist(fname,'file')==2,
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
if exist([pwd,filesep,obj.refhist.fname])
    try
        obj.refhist.data=read_eas(obj.refhist.fname);
    end
end
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
try
    obj.refhist.do_discrete=tmp(2);
catch
    obj.refhist.do_discrete=0;
end
obj.refhist.nGsim=1000;
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
            if (size(obj.out.data,1)==nxyz*obj.nsim)
                nsim=obj.nsim;
            else
                % THIS IS POTENTIALLY DANGEROUS WHEN RUNNING THE PAR FILE
                % TWICE WITH NSIM SMALLLER IN RUN2 THAN in RUN1
                % THEN NSIM2=NSIM1. ONLY A PROB WHEN obj.out EXIST
                %
                nsim=length(obj.out.data)./(nxyz);
                nsim=floor(nsim);
                %nsim=obj.nsim;
                disp(sprintf('%s : Setting nsim=%d,%d',mfilename,obj.nsim,nsim))
            end
        else
        end
        nsim=obj.nsim;
        if nsim>0
            if obj.nz==1,
                obj.D=reshape(obj.out.data(1:(nsim*nxyz)),obj.nx,obj.ny,nsim);
            else
                obj.D=reshape(obj.out.data(1:(nsim*nxyz)),obj.nx,obj.ny,obj.nz,nsim);
            end
            obj.D(find(obj.D==UNEST))=NaN;
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
        else
            fname=['visim_estimation_',obj.out.fname];
            if exist([pwd,filesep,fname],'file');
                [d]=read_eas(fname);
                d(find(d==UNEST))=NaN;
                try
                    obj.etype.mean=reshape(d(:,1),obj.nx,obj.ny);
                    obj.D=obj.etype.mean;
                    obj.etype.var=reshape(d(:,2),obj.nx,obj.ny);
                catch
                    mgstat_verbose(sprintf('%s : Failed to load estimations results from %s',mfilename,fname),8)
                end
            end
        end
        
    end
    
catch
    disp('something went wrong in read_visim ...')
end

% read mask file if it exists
%f_mask=sprintf('%s%smask_%s.out',par_path,filesep,par_file);
try
    f_mask=sprintf('mask_%s.out',par_file);
    if exist(f_mask,'file')
        obj.mask.data=read_eas(f_mask);
        obj.mask.enable=1;
    else
        obj.mask.data=ones(1,obj.nx*obj.ny*obj.nz);
        obj.mask.enable=0;
    end
    obj.mask.mask=reshape(obj.mask.data,[obj.nx,obj.ny,obj.nz])';
end

fclose(fid);


function [str_out]=get_string(str)

fspace=find(str==' ');
if length(fspace>0)
    str_out=str(1:fspace(1)-1);
else
    str_out=str;
end

