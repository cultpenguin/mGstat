% krig_sk : Simple Kriging
%
% Call :
%  function [d_est,d_var,lambda_sk,K_sk,k_sk]=krig_sk(pos_known,val_known,pos_est,V,val_0,gvar,noise_known);
%
% TMH/2005
%

function [d_est,d_var,lambda_sk,K_sk,k_sk]=krig_sk(pos_known,val_known,pos_est,V,val_0,gvar,noise_known);

   if isstr(V),
    V=deformat_variogram(V);
  end 
  
  if nargin==4,
    val_0=mean(val_known);
  end
  
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
  usemax=114;
  usemax=min(usemax,nknown);
  
  d_known=d(order_list(1:usemax));
  pos_known=pos_known(order_list(1:usemax),:);
  val_known=val_known(order_list(1:usemax),:);
  nknown=size(pos_known,1);
  
  
  if exist('gvar')==0;
    if length(V)==1,
      gvar=V.par1;
    else
      gvar=sum([V.par1]);
    end
  end
  
  % Data to Data matrix
  K_sk=zeros(nknown,nknown);
  for i=1:nknown;
    for j=1:nknown;
      d=edist(pos_known(i,:),pos_known(j,:));
      K_sk(i,j)=gvar-semivar_synth(V,d);
      if i==j
        if exist('noise_known')==1
          if length(noise_known)==1,
            K_sk(i,j)=K_sk(i,j)+noise_known;
          else
            K_sk(i,j)=K_sk(i,j)+noise_known(i);
          end
        end
      end
    end
  end
  
  % Data to Unknown matrix
  k_sk=zeros(nknown,1);
  for i=1:nknown;
    d=edist(pos_known(i,:),pos_est);      
    k_sk(i)=gvar-semivar_synth(V,d);
  end
  
  lambda_sk = inv(K_sk)*k_sk;
  
  d_est = (val_known' - val_0)*lambda_sk(:)+ val_0;
  d_var = gvar - k_sk'*inv(K_sk)*k_sk;