function err=GstatOptim(x)
load semivar_optim_dummy
sv_calc=0.*h;
V(1).type='Lin';
V(1).par1=x(1);
V(1).par2=x(2);
sv_synth=semivar_synth(V,h);

nn=find(~isnan(sv_obs));
err=sum(sqrt((sv_synth(nn)-sv_obs(nn)).^2));
