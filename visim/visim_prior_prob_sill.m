% visim_prior_prob_sill : Find sill froma fixed set of ranges
%
function [V,opt_sill,Lmean,options,out]=visim_prior_prob_sill(V,options)

gvar_est=[];
if nargin<1 
    help(mfilename)
    return;
end

if nargin<2
    options.null='';
end

if ~isfield(options,'maxit')
    options.maxit=10;
end

% SILL ARRAYS FOR TESTING
if ~isfield(options,'sill_range')
    try
        v0=var(V.fvolsum.data(:,3));
        options.sill_range=linspace(v0,10*v0,10);

    catch
        options.sill_range=[1e-5:1e-5:2e-4];
    end
end

% RANGES FOR TESTING
if isfield(options,'a_hmax')==0, options.a_hmax.null=0;end
if isfield(options,'a_hmin')==0, options.a_hmin.null=0;end
if isfield(options,'a_vert')==0, options.a_vert.null=0;end
if isfield(options,'ang1')==0, options.ang1.null=0;end
if isfield(options,'ang2')==0, options.ang2.null=0;end
if isfield(options,'ang3')==0, options.ang3.null=0;end

% RANGES
if isfield(options.a_hmax,'min')==0,  options.a_hmax.min=V.Va.a_hmax; end
if isfield(options.a_hmin,'min')==0,  options.a_hmin.min=V.Va.a_hmin; end
if isfield(options.a_vert,'min')==0,  options.a_vert.min=V.Va.a_vert; end
if isfield(options.a_hmax,'max')==0,  options.a_hmax.max=V.Va.a_hmax; end
if isfield(options.a_hmin,'max')==0,  options.a_hmin.max=V.Va.a_hmin; end
if isfield(options.a_vert,'max')==0,  options.a_vert.max=V.Va.a_vert; end
d_int=4;
if isfield(options.a_hmax,'step')==0,
    options.a_hmax.step= (options.a_hmax.max-options.a_hmax.min)/d_int;
end
if isfield(options.a_hmin,'step')==0,
    options.a_hmin.step= (options.a_hmin.max-options.a_hmin.min)/d_int;
end
if isfield(options.a_vert,'step')==0,
    options.a_vert.step= (options.a_vert.max-options.a_vert.min)/d_int;
end

if isfield(options,'nsim')==0,
    options.nsim=5;
end

if (options.a_hmax.step==0); options.a_hmax.step=1; end
if (options.a_hmin.step==0); options.a_hmin.step=1; end
if (options.a_vert.step==0); options.a_vert.step=1; end

options.h1_arr=options.a_hmax.min:options.a_hmax.step:options.a_hmax.max;
options.h2_arr=options.a_hmin.min:options.a_hmin.step:options.a_hmin.max;
options.h3_arr=options.a_vert.min:options.a_vert.step:options.a_vert.max;

V.parfile='testsill.par';
V.nsim=options.nsim;
options.pure_sill=1;

for ih1=1:length(options.h1_arr)
for ih2=1:length(options.h2_arr)
for ih3=1:length(options.h3_arr)
    V.Va.a_hmax=options.h1_arr(ih1);
    V.Va.a_hmin=options.h2_arr(ih2);
    V.Va.a_vert=options.h3_arr(ih3);
    for isill=1:length(options.sill_range);
        mgstat_verbose(sprintf('%s : r(%g,%g,%g) sill=%g',mfilename,V.Va.a_hmax,V.Va.a_hmin,V.Va.a_vert,V.gvar),2)
        V.gvar=options.sill_range(isill);
        V.Va.cc=V.gvar; % Variance
        [Lmean(isill,ih1,ih2,ih3),Vu,Vc,out{isill,ih1,ih2,ih3}]=visim_prior_prob(V,options);        
    end
    Lm=Lmean(:,ih1,ih2,ih3);
    imax=find(Lm==max(Lm));
    opt_sill(ih1,ih2,ih3)=options.sill_range(imax(1));
    save SILL
end
end
end


