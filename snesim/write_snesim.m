% read_snesim : Read SNESIM (v10) parameter file
%
%  S = read_snesim_10(filename,read_data);
%     filename [string]: snesim parameter file (def:'snesim.par')
%     read_data [integer]: optionally read input/output data files
%          read_data=0; % read no data
%          read_data=1; % read output from visim
%          read_data=2; % read all input and output from visim
%
%  S is a Matlab structure will all options for running SNESIM
%
% See also: write_snesim_10, snesim
%
function obj=read_snesim_10(filename,read_data)

if nargin==0;
    filename='snesim.par';
end
if nargin<2
    read_data=0;
end

if exist(filename,'file')~=2,
    help(mfilename)
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
    if (read_data>1);
        obj.fconddata.data=read_eas(fname);
    end
catch
    disp(sprintf('%s : Could not read conditional data : %s',mfilename,fname));
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
    if read_data>1
        obj.fvertprob.data=read_eas(obj.fvertprob.fname);
    end
end

% servo system
line=fgetl(fid);
data=sscanf(line,'%f');
obj.servosystem=data(1);

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
    if (read_data>0)
        obj.out.data=read_eas(obj.out.fname);
    end
catch
    obj.out.data=[];
end

% NSIM
line=fgetl(fid);
obj.nsim=sscanf(line,'%f');

% DIM INFO
line=fgetl(fid);
tmp=sscanf(line,'%d %f %f');
obj.dim.nx=tmp(1);obj.dim.xmn=tmp(2);obj.dim.xsiz=tmp(3);
line=fgetl(fid);
tmp=sscanf(line,'%d %f %f');
obj.dim.ny=tmp(1);obj.dim.ymn=tmp(2);obj.dim.ysiz=tmp(3);
line=fgetl(fid);
tmp=sscanf(line,'%d %f %f');
obj.dim.nz=tmp(1);obj.dim.zmn=tmp(2);obj.dim.zsiz=tmp(3);
obj.dim.x=[0:1:obj.dim.nx-1]*obj.dim.xsiz+obj.dim.xmn;
obj.dim.y=[0:1:obj.dim.ny-1]*obj.dim.ysiz+obj.dim.ymn;
obj.dim.z=[0:1:obj.dim.nz-1]*obj.dim.zsiz+obj.dim.zmn;


% RSEED
line=fgetl(fid);
obj.rseed=sscanf(line,'%f');

%% template
%line=fgetl(fid);
%obj.ftemplate.fname=get_string(line);
%try
%    obj.ftemplate.data=read_eas(obj.ftemplate.fname);
%end

% max cond data
line=fgetl(fid);
obj.max_cond=sscanf(line,'%f');

% max number of replicates
line=fgetl(fid);
obj.min_replicates=sscanf(line,'%f');

% condition to LP
line=fgetl(fid);
tmp=sscanf(line,'%d %d');
obj.condition_to_lp=tmp(1);
obj.iauto=tmp(2);


% tau1, tau2
line=fgetl(fid);
tmp=sscanf(line,'%f %f');
obj.tau1=tmp(1);
obj.tau2=tmp(2);

% localprob
line=fgetl(fid);
obj.flocalprob.fname=get_string(line);

% rotation and affinity
line=fgetl(fid);
tmp=sscanf(line,'%d');
obj.frotaff.use=tmp(1);

line=fgetl(fid);
obj.frotaff.fname=get_string(line);

line=fgetl(fid);
tmp=sscanf(line,'%d');
obj.frotaff.n_cat=tmp(1);
for i=1:obj.frotaff.n_cat
    line=fgetl(fid);
    tmp=sscanf(line,'%f %f %f');
    obj.frotaff.aff_xyz(i,:)=tmp;
end


% n multiple grids
line=fgetl(fid);
data=sscanf(line,'%f');
obj.n_mulgrids=data(1);

% Training image
line=fgetl(fid);
obj.ti.fname=get_string(line);
if (read_data>1)
    obj.ti.data=read_eas(obj.ti.fname);
end

% ti dim
line=fgetl(fid);
data=sscanf(line,'%f');
obj.ti.nx=data(1);
obj.ti.ny=data(2);
obj.ti.nz=data(3);

if (read_data>1)
    if obj.ti.nz==1
        obj.ti.data=reshape(obj.ti.data,obj.ti.nx,obj.ti.ny)';
    else
        obj.ti.data=reshape(obj.ti.data,obj.ti.nx,obj.ti.ny,obj.ti.nz);
    end
end
line=fgetl(fid);
obj.ti.col_var=sscanf(line,'%f');

% Search radius
line=fgetl(fid);
data=sscanf(line,'%f');
obj.search_radius.hmax=data(1);
obj.search_radius.hmin=data(2);
obj.search_radius.hvert=data(3);
% Search angles
line=fgetl(fid);
data=sscanf(line,'%f');
obj.search_radius.amax=data(1);
obj.search_radius.amin=data(2);
obj.search_radius.avert=data(3);

if (read_data>0)
    nsim=obj.nsim;
    nxyz=obj.dim.nx*obj.dim.ny*obj.dim.nz;
    if (nsim>0)&(~isempty(obj.out.data))
        %try
        if obj.dim.nz==1,
            obj.D=reshape(obj.out.data(1:(nsim*nxyz)),obj.dim.nx,obj.dim.ny,nsim)';
        else
            obj.D=reshape(obj.out.data(1:(nsim*nxyz)),obj.dim.nx,obj.dim.ny,obj.dim.nz,nsim);
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
        %catch
        %    disp(sprintf('FAILED TO LOAD DATA',nsim));
        %end
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

