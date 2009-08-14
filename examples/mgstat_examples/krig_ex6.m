rand('seed',1)
ndata=30;
pos_known=rand(ndata,1)*10;
val_known=randn(ndata,1); % 
val_var=zeros(ndata,1)+.1; % 
V='1 Sph(.1)';      % Select variogram model
pos_est=[-2:.1:12]';
clear options;options.max=4;
[d_est_ok,d_var_ok]=krig(pos_known,[val_known val_var],pos_est,V,options);
options.mean=mean(val_known);
[d_est_sk,d_var_sk]=krig(pos_known,[val_known val_var],pos_est,V,options);
options.polytrend=1;
[d_est_kt,d_var_kt]=krig(pos_known,[val_known val_var],pos_est,V,options);
plot(pos_est,[d_est_sk,d_est_ok,d_est_kt],'-',pos_known,val_known,'k*')
legend('SK','OK','KT','Data')
print -dpng krigex6