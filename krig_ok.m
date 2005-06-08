% krig_ok : Ordinary Kriging
%
% Call :
%   [d_est,d_var,lambda_ok,d_mean]=krig_ok(pos_known,val_known,pos_est,V,Kin,kin;)
%
% TMH/2005
%
function [d_est,d_var,lambda_ok,d_mean]=krig_ok(pos_known,val_known,pos_est,V,Kin,kin);

  % if DoGraphics=1, some illustrative plotting is generated
  % if DoGraphics=0, no grapics will be generated
    DoGraphics=0;

  
  if isstr(V),
    V=deformat_variogram(V);
  end 
  
  if nargin==4,
    val_0=0;
  end
  
  nknown=size(pos_known,1);
  ndim=size(pos_known,2);
  
  if ndim<=2,
    DoGraphics==0;
  end
  
  
  % FIRST FIND THE CLOSEST DATA
  d=zeros(nknown,1);
  for ir=1:nknown
    d(ir)=edist(pos_est,pos_known(ir,:));
  end
  id=[1:nknown]';
  order_list=sortrows([id,d],[2]);
  order_list=order_list(:,1);
  
  % SELECT NEIGHBORHOOD
  usemax=16;
  usemax=min(usemax,nknown);
  
  d_known=d(order_list(1:usemax));
  pos_known=pos_known(order_list(1:usemax),:);
  val_known=val_known(order_list(1:usemax),:);
  nknown=size(pos_known,1);

  %% RESHAPE INPUT COVARIANCE FUNCTIONS IF PRESENTED
  if exist('Kin')
    Kin2=zeros(nknown,nknown);      
    for i=1:nknown;
      for j=1:nknown;
        Kin2(i,j)=Kin(order_list(i),order_list(j));
      end
    end
    Kin=Kin2;
  end  
  
  if exist('kin')
    kin=kin(order_list(1:nknown));
  end
  
  
  % Data to Data matrix
  K_ok=zeros(nknown+1,nknown+1);
  if exist('Kin');
    K_ok(1:nknown,1:nknown)=Kin;
  else
    for i=1:nknown;
      for j=1:nknown;
        d=edist(pos_known(i,:),pos_known(j,:));
        %d=sqrt([pos_known(i,:)-pos_known(j,:)]*[pos_known(i,:)-pos_known(j,:)]');
        K_ok(i,j)=sum([V.par1])-semivar_synth(V,d);
      end
    end
  end
  K_ok(nknown+1,1:nknown)=ones(1,nknown);
  K_ok(1:nknown,nknown+1)=ones(nknown,1);
  
  % Data to Unknown matrix
  k_ok=zeros(nknown+1,1);
  if exist('kin')==1
    k_ok(1:nknown)=kin;
  else
    for i=1:nknown;
      d=edist(pos_known(i,:),pos_est);
      k_ok(i)=sum([V.par1])-semivar_synth(V,d);
    end
  end
  k_ok(nknown+1)=1;
  
  lambda_ok = inv(K_ok)*k_ok;
  
  d_mean=lambda_ok(nknown+1);
  d_mean=mean(val_known);
  
  lambda_ok=lambda_ok(1:nknown);
  
  d_est = val_known'*lambda_ok(1:nknown);
  d_var = sum([V.par1]) - k_ok'*inv(K_ok)*k_ok;
  
  %for i=1:nknown
  %  disp(sprintf('d=%4.2g val=%4.2g  weight=%4.2g',d_known(i),val_known(i),lambda_ok(i)))
  %end
  %disp(sprintf('Estimate = %4.2g +- %4.2g',d_est,d_var))
    
  end

