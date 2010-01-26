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
function [d_est,d_var,be,d_diff,L]=gstat_krig_blinderror(pos_known,val_known,pos_est,V,options);
   
  if isfield(options,'T');
    T=options.T;
  else
    T=1;
  end
  
  if ischar(V),
    V=deformat_variogram(V);
  end 
  
  options.xvalid=1;
  
  [d_est,d_var]=gstat_krig(pos_known,val_known,pos_est,V,options);
  d_diff=d_est-val_known(:,1);
  be=mean(abs(d_diff));
  
  
  if nargout==5
    % CALULATE LIKELIHOOD
    nd=size(val_known,1);
    Cd=zeros(nd,nd);
    for i=1:nd
      Cd(i,i)=d_var(i);
    end
    L=exp(-.5*d_diff'*inv(Cd)*d_diff./T);
    
  end