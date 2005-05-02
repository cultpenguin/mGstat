% krig_trend_trend : Krig the trend of kriging with a trend
%
% Call :
% [d_est,d_var,lambda_trend]=krig_trend_trend(pos_known,val_known,pos_est,V);
%
%
function [d_est,d_var,lambda_trend]=krig_trend_trend(pos_known,val_known,pos_est,V);

  nknown=size(pos_known,1);
  ndim=size(pos_known,2);
  
  % FIRST FIND THE CLOSEST DATA
  d=zeros(nknown,1);
  for ir=1:nknown
    d(ir)=edist(pos_est,pos_known(ir,:));
  end
  id=[1:nknown]';
  order_list=sortrows([id,d],[2]);
  order_list=order_list(:,1);
  % SELECT NEIGHBORHOOD
  usemax=15;
  usemax=min(usemax,nknown);
  
  d_known=d(order_list(1:usemax));
  pos_known=pos_known(order_list(1:usemax),:);
  val_known=val_known(order_list(1:usemax),:);
  nknown=size(pos_known,1);
  
  
  gvar=sum([V.par1]);
  
  
  % Data to Data matrix
  K_trend=zeros(nknown+1+ndim,nknown+ndim);
  for i=1:nknown;
    for j=1:nknown;
      d=edist(pos_known(i,:),pos_known(j,:));
      K_trend(i,j)=gvar-semivar_synth(V,d);
    end
  end
  K_trend(nknown+1,1:nknown)=ones(1,nknown);
  K_trend(1:nknown,nknown+1)=ones(nknown,1);
  for id=1:ndim
    K_trend(nknown+1+id,1:nknown)=pos_known(:,id)';
    K_trend(1:nknown,nknown+1+id)=pos_known(:,id);
  end
  
  % Data to Unknown matrix
  k_trend=zeros(nknown+1+ndim,1);
  for i=1:nknown;
    d=edist(pos_known(i,:),pos_est);
    k_trend(i)=gvar-semivar_synth(V,d);
    k_trend(i)=0; % TO KIRG THE TREND
  end
  k_trend(nknown+1)=1;
  for id=1:ndim
    k_trend(nknown+1+id)=pos_est(id);
  end
  
  
  lambda_trend = inv(K_trend)*k_trend;
  
  d_mean=lambda_trend(nknown+1);
  lambda_trend=lambda_trend(1:nknown);
  
  d_est = val_known'*lambda_trend(:);
  d_var = gvar - k_trend'*inv(K_trend)*k_trend;