function S=snesim_init

% call: S=snesim_init

%Data file:
S.fconddata.fname='data.dat'; 
%Input columns: 
S.fconddata.xcol=1;
S.fconddata.ycol=2;
S.fconddata.zcol=3;
S.fconddata.vcol=4;
%Number of categories:
S.ncat=2; %length(S.cat_code)
%Categories:
S.cat_code(1)=0;
S.cat_code(2)=1;
% Target PDF
S.pdf_target(1)=0.7;
S.pdf_target(2)=0.3;
% Use target vertical proportions:
S.use_vert_prop=0; % (0 or 1)
%Vertical proportions file: 
S.fvertprob.fname='vertprop.dat';
%Servosystem correction: 
S.pdf_target_repro=1; %(0 or 1)
S.pdf_target_par=0.5; %(between 0 and 1)
%Debugging level:
S.debug_level=-2;
%Debugging file:
S.fdebug.fname='snesim.dbg';
%Output file:
S.out.fname='snesim.out';
%Number of realizations
S.nsim=1;
%X, Y, and Z grid specification:
S.nx=80;S.xmn=0.25;S.xsiz=0.5;
S.ny=120;S.ymn=0.25;S.ysiz=0.5;
S.nz=1;S.zmn=0.25;S.zsiz=0.5;
%Random number seed:
S.rseed=500;
%Data template file:
S.ftemplate.fname='template48.dat';
%Maximum conditioning data: 
S.max_cond=16;
%Maximum conditioning data per octant:
S.max_data_per_oct=0;
%Min. number of replicates:
S.max_data_events=20;
%Multiple grid simulation:
S.n_mulgrids=2; 
S.n_mulgrids_w_stree=1;
%Training image file, 
S.fti.fname='largetrain.dat';
%Training grid dimensions, 
S.nxtr=250;
S.nytr=250;
S.nztr=1;
%Column for variable:
S.fti.col_var=1;
%Data search neighbourhood radii:
S.hmax=10;
S.hmin=10;
S.hvert=5;
%Search anisotropy angles
S.amax=7;
S.amin=3;
S.avert=0;
S.parfile='snesim.par';
