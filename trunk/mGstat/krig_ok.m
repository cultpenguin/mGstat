% krig_ok : Ordinary Kriging
%
% Call :
%   [d_est,d_var,lambda_ok,d_mean]=krig_ok(pos_known,val_known,pos_est,V;)
%
% TMH/2005
%
function [d_est,d_var,lambda_ok,d_mean]=krig_ok(pos_known,val_known,pos_est,V);

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
  
  if DoGraphics==1;
    if ndim==1
      subplot(2,2,1)
      plot(pos_known,val_known,'k.','MarkerSize',15)
      hold on
      plot(pos_est,mean(val_known),'g*')
      hold off
      legend('Known','Unknown')
    else      
      cax=([min(val_known) max(val_known)]);
      subplot(2,2,1)
      scatter(pos_known(:,1),pos_known(:,2),20,val_known,'filled')
      hold on
      plot(pos_est(:,1),pos_est(:,2),'g*')
      hold off
      caxis(cax)
      colormap(jet)
      axis image
      title('The Known Data')
      colorbar
    end
  end
  
  
  % FIRST FIND THE CLOSEST DATA
  d=zeros(nknown,1);
  for ir=1:nknown
    d(ir)=edist(pos_est,pos_known(ir,:));
  end
  id=[1:nknown]';
  order_list=sortrows([id,d],[2]);
  order_list=order_list(:,1);
  
  
  if DoGraphics==1;
    if ndim==1
      subplot(2,2,2)
      bar(pos_known,d)
      hold on
      plot(pos_est,mean(val_known),'g*')
      hold off
      ylabel('Distance to data')
      legend('','Known','Unknown')
    else      
      subplot(2,2,2)
      scatter(pos_known(:,1),pos_known(:,2),20,d,'filled')
      axis image
      hold on
      plot(pos_est(:,1),pos_est(:,2),'g*')
      hold off
      title('Distance to data')
      colorbar
    end
  end
  
  % SELECT NEIGHBORHOOD
  usemax=6;
  usemax=min(usemax,nknown);
  
  d_known=d(order_list(1:usemax));
  pos_known=pos_known(order_list(1:usemax),:);
  val_known=val_known(order_list(1:usemax),:);
  nknown=size(pos_known,1);
  
  
  if DoGraphics==1;
    if ndim==1
      hold on
      plot(pos_known,d_known,'r.','MarkerSize',40)
      hold off
      legend('all data','Unknown','used data')
    else            
      hold on
      plot(pos_known(:,1),pos_known(:,2),'r+')
      hold off
      legend('all data','used data')
    end
  end



  % Data to Data matrix
  K_ok=zeros(nknown+1,nknown+1);
  for i=1:nknown;
    for j=1:nknown;
      d=edist(pos_known(i,:),pos_known(j,:));
      %d=sqrt([pos_known(i,:)-pos_known(j,:)]*[pos_known(i,:)-pos_known(j,:)]');
      K_ok(i,j)=sum([V.par1])-semivar_synth(V,d);
    end
  end
  K_ok(nknown+1,1:nknown)=ones(1,nknown);
  K_ok(1:nknown,nknown+1)=ones(nknown,1);
  
  % Data to Unknown matrix
  k_ok=zeros(nknown+1,1);
  for i=1:nknown;
    d=edist(pos_known(i,:),pos_est);
    % d=sqrt([pos_known(i,:)-pos_est]*[pos_known(i,:)-pos_est]');
    k_ok(i)=sum([V.par1])-semivar_synth(V,d);
  end
  k_ok(nknown+1)=1;
  
  lambda_ok = inv(K_ok)*k_ok;
  
  d_mean=lambda_ok(nknown+1);
  d_mean=mean(val_known);
  
  lambda_ok=lambda_ok(1:nknown);
  
  d_est = val_known'*lambda_ok(1:nknown);
  d_var = sum([V.par1]) - k_ok'*inv(K_ok)*k_ok;
  
  
  if DoGraphics==1;
    if ndim==1
      

      subplot(2,2,3)
      bar(pos_known,lambda_ok)
      ax=axis;axis([ax(1) ax(2) 0 1])
      ylabel('\lambda')
      title('Weight of used data')
      
      subplot(2,2,4)
      plot(pos_known,val_known,'k.','MarkerSize',45)
      hold on
      plot(pos_est,d_est,'g.','MarkerSize',45)
      plot(pos_est,d_est-d_var,'g.','MarkerSize',15)
      plot(pos_est,d_est+d_var,'g.','MarkerSize',15)
      hold off
      legend('Known','Estimated')
      xlabel('X [km]')
      xlabel('Value')
      
      drawnow;
      % pause(.1)
    else      
      subplot(2,2,3)
      scatter(pos_known(:,1),pos_known(:,2),40,lambda_ok,'filled')
      hold on
      plot(pos_est(:,1),pos_est(:,2),'k*','markersize',10)
      hold off
      axis image
      title('Weight Of Data')
      % caxis(cax)
      colorbar
      
      subplot(2,2,4)
      scatter(pos_known(:,1),pos_known(:,2),40,val_known,'filled')
      hold on
      scatter(pos_est(:,1),pos_est(:,2),100,d_est,'filled')
      hold off
      axis image
      title('Estimation')
      caxis(cax)
      colorbar
      %legend('used data','Estimated value',-1)
      drawnow
    end
    
    for i=1:nknown
      disp(sprintf('d=%4.2g val=%4.2g  weight=%4.2g',d_known(i),val_known(i),lambda_ok(i)))
    end
    disp(sprintf('Estimate = %4.2g +- %4.2g',d_est,d_var))
    
  end

