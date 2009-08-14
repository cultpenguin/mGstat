pos_known=[1;5;10];
val_known=[0;3;2]; % adding some uncertainty
V='1 Sph(.2)';      % Select variogram model
pos_est=[2]';
[d_est,d_var]=krig(pos_known,val_known,pos_est,V)
