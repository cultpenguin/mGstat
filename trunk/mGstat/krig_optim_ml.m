function [Vop2,Vop1]=krig_optim_ml(pos_known,val_known,V,options)

if nargin==3;
  options.dummy='';
end

options.isorange=1;

if isfield(options,'maxit')==0
  options.maxit=10;
end


% FIRST SAMPLE THE ATTRIBUTE SPACE
[V,be,L,par2,nugfrac,Vall]=krig_optim_mcmc(pos_known,val_known,V,options);
iop=find(L==max(L));iop=iop(1);
Vop1=Vall{iop};

% THEN LOOK FOR THE LOCAL MAX LIKELIHOOD MODEL
options.step_nugfrac=options.step_nugfrac.*.01;
options.step_range=options.step_range.*.01;
options.descent=1;
[Vop2,be,L,par2,nugfrac,Vall]=krig_optim_mcmc(pos_known,val_known,Vop1,options);

