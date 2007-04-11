% krig_optim_ml : MCMC Maximum likelihood optimization
%
% Call : 
%
%    [Vop2,Vop1,be,L,par2,nugfrac,Vall]=krig_optim_ml(pos_known,val_known,V,options)
%
function [Vop2,Vop1,be,L,par2,nugfrac,Vall,mcmc_out]=krig_optim_ml(pos_known,val_known,V,options)

if nargin==3;
  options.dummy='';
end

options.isorange=1;

if isfield(options,'maxit')==0
  options.maxit=10;
end


if (isfield(options,'step_range')==0)
  options.step_range=std(pos_known)/4;
end

if (isfield(options,'step_nugfrac')==0)
  options.step_nugfrac=.1;
end

% FIRST SAMPLE THE ATTRIBUTE SPACE
[V,be,L,par2,nugfrac,Vall,options]=krig_optim_mcmc(pos_known,val_known,V,options);
iop=find(L==max(L));iop=iop(1);
Vop1=V;

mcmc_out.V=V;
mcmc_out.be=be;
mcmc_out.par2=par2;
mcmc_out.nugfrac=nugfrac;
mcmc_out.Vall=Vall;
mcmc_out.L=L;

% THEN LOOK FOR THE LOCAL MAX LIKELIHOOD MODEL
options.step_nugfrac=options.step_nugfrac.*.01;
options.step_range=options.step_range.*.01;
options.descent=1;

if isfield(options,'plot')==1
    if options.plot==1; figure; end
end
try
  [Vop2,be2,L2,par22,nugfrac2,Vall2]=krig_optim_mcmc(pos_known,val_known,Vop1,options);
catch
  Vop2=Vop1
end
return
