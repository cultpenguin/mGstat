% gstat_krig_blinderror : blind cross validation using gstat
%
% Call as gstat_krig is called : 
%    [d_est,d_var,be,d_diff]=gstat_krig_blinderror(pos_known,val_known,pos_est,V,options);
%
% [d_est,d_var] : Cross validation prediction
% [be] : Cross validation error
%
% /TMH 12/2005
%
function [d_est,d_var,be,d_diff]=gstat_krig_blinderror(pos_known,val_known,pos_est,V,options);
  
  options.xvalid=1;
  
  [d_est,d_var]=gstat_krig(pos_known,val_known,pos_est,V,options);
  d_diff=d_est-val_known;
  be=mean(abs(d_diff));
  