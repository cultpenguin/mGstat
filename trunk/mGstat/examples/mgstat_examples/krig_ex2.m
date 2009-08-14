pos_known=[1;5;10];
val_known=[0;3;2]; % 
V='1 Sph(.2)';      % Select variogram model
pos_est=[0:.1:10]';
[d_est,d_var]=krig(pos_known,val_known,pos_est,V);
plot(pos_est,d_est,'k',pos_known,val_known,'ro')
print -dpng krigex2