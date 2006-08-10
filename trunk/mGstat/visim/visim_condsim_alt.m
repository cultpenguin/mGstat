% visim_condsim_alt
%
%
V=read_visim('visim_test.par');

% CONDITIONAL ESTIMATION
Vcond_est=V;
Vcond_est.nsim=0;
Vcond_est.parfile='Cest';
Vcond_est=visim(Vcond_est);
v_cest=Vcond_est.etype.mean';
% UNCONDITIONAL SIMULATION
Vuncond_sim=V;
Vuncond_sim.cond_sim=0;
Vuncond_sim.nsim=1;
Vuncond_sim.parfile='Usim';
Vuncond_sim=visim(Vuncond_sim);
v_usim=Vuncond_sim.D';

% CALCULATE ERRORS
[G,d_est]=visim_to_G(Vuncond_sim);
d_obs=Vuncond_sim.fvolsum.data(:,3);
%v=v_cest';v=v(:);
v=v_usim';v=v(:);
d_est=G*v;

volsum=read_eas(V.fvolsum.fname);
volsum(:,3)=d_est;
write_eas('err.eas',volsum);
Vcond_est2=V;
Vcond_est2.nsim=0;
Vcond_est2.fvolsum.fname='err.eas';
Vcond_est2.parfile='Cest2';
Vcond_est2=visim(Vcond_est2);
v_cest_err=Vcond_est2.etype.mean';

%% COMBINE 

v_csim = v_cest + ( v_usim - v_cest_err ); 
%


subplot(2,3,4)
plot(d_est,d_obs);
xlabel('uncond estimates');ylabel('observations')
axis image


cax=[.11 .15];
subplot(2,3,1);
imagesc(V.x,V.y,v_cest);axis image;caxis(cax)
subplot(2,3,2);
imagesc(V.x,V.y,v_usim);axis image;caxis(cax)
subplot(2,3,3);
imagesc(V.x,V.y,v_cest_err);axis image;caxis(cax)
subplot(2,3,6);
imagesc(V.x,V.y,v_csim);axis image;caxis(cax)
v_cest_err
%


