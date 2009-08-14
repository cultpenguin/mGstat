pos_known=[1;5;10]; %
val_known=[0;3;2];  % 
V='1 Sph(.2)';      % Select variogram model
pos_est=[0:.1:10]';
[d_est_ok,d_var_ok]=krig(pos_known,val_known,pos_est,V);
options.mean=2;
[d_est_sk,d_var_sk]=krig(pos_known,val_known,pos_est,V,options);
options.trend=1;
[d_est_kt,d_var_kt]=krig(pos_known,val_known,pos_est,V,options);
plot(pos_est,[d_est_sk,d_est_ok,d_est_kt],'-',pos_known,val_known,'ro')
legend('SK','OK','KT','Data')
print -dpng krigex3