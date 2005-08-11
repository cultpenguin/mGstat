% krig_sk : Simple Kriging
%
% Call :
% [d_est,d_var,lambda_sk,K_dd,k_du,inhood]=krig(pos_known,val_known,pos_est,V,val_0);
%
% ndata : number of data observations
% ndims : dimensions of data location (>=1)
% nest  : number of data locations to be estimated
%
% pos_known [ndata,ndims] : Locations of data observations
% val_known [ndata,1 or 2]  : col1 : Data value as measured at 'pos_known'
%                             col2 : Data uncertainty as measured at
%                             'pos_known' (optional)
% pos_est   [1 ,ndims] : Location of data to be estimated
% V : Variogram model, e.g. '1 Sph(100)'
% val_0 : A priori assumed data value (default=mean(val_known))
%
%
%
% Example 1D - NO DATA UNCERTAINTY
% profile on
% pos_known=10*rand(10,1);
% val_known=rand(size(pos_known)); % adding some uncertainty
% pos_est=[0:.01:10]';
% V=deformat_variogram('1 Sph(1)');
% for i=1:length(pos_est);
%   [d_est(i),d_var(i)]=krig(pos_known,val_known,pos_est(i),V);
% end
% plot(pos_est,d_est,'r.',pos_est,d_var,'b.',pos_known,val_known(:,1),'g*')
% legend('SK estimate','SK variance','Observed Data')
% %title(['V = ',V])
% profile viewer
%
% See source code for more examples
%
%

% Example 1 : 1D - NO DATA UNCERTAINTY
% pos_known=[1;5;10];
% val_known=[0 3 2]'; % adding some uncertainty
% pos_est=[0:.01:10]';
% V='1 Sph(.2)';
% for i=1:length(pos_est);
%   [d_est(i),d_var(i)]=krig(pos_known,val_known,pos_est(i),V);
% end
% plot(pos_est,d_est,'r.',pos_est,d_var,'b.',pos_known,val_known(:,1),'g*')
% legend('SK estimate','SK variance','Observed Data')
% title(['V = ',V])
%
% Example 2 : 1D - Data Uncertainty 
% pos_known=[1;5;10];
% val_known=[0 3 2;0 1 0]'; % adding some uncertainty
% pos_est=[0:.01:10]';
% V=deformat_variogram('1 Sph(2)');
% for i=1:length(pos_est);
%   [d_est(i),d_var(i)]=krig(pos_known,val_known,pos_est(i),V);
% end
% plot(pos_est,d_est,'r.',pos_est,d_var,'b.',pos_known,val_known(:,1),'g*')
% legend('SK estimate','SK variance','Observed Data')
% title(['using data uncertainty, V = ',V])
%
%
% Example 3 : 2D : 
% pos_known=[0 1;5 1;10 1];
% val_known=[0 3 2]';
% pos_est=[1.1 1];
% V='1 Sph(2)';
% [d_est,d_var]=krig(pos_known,val_known,pos_est,V);
%
%

% TMH/2005
%

function [d_est,d_var,lambda_sk,K_sk,k_sk,inhood]=krig(pos_known,val_known,pos_est,V,options);

  if isstr(V),
    V=deformat_variogram(V);
  end 

  if nargin<5
    options.null=0;
  end
  
  
  if any(strcmp(fieldnames(options),'mean')); 
    val_0=options.mean;
  else
    val_0=mean(val_known(:,1));
  end
  
  if size(val_known,2)==1;
    % Specify uncertainty of zero;
     val_known=repmat(val_known(:,1),1,2);
     val_known(:,2)=0; % NO UNCERTAINTY
  end
  
  nknown=size(pos_known,1);
  ndim=size(pos_known,2);
  n_est=size(pos_est,1);
  if n_est~=1, 
    mgstat_verbose('Warning : you called krig with more than one')
    mgstat_verbose('unknown data location')
    mgstat_verbose('--- Calling krig_npoint instead')
    [d_est,d_var,d2d,d2u]=krig_npoint(pos_known,val_known,pos_est,V,options);
    lambda_sk=[];K_sk=[];k_sk=[];inhood=[];
    return
  end
      
  % SELECT NEIGHBORHOOD
  [inhood,order_list]=nhood(pos_known,pos_est,options);
  %inhood=1:1:nknown;
  %order_list=1:1:nknwon;
  
  pos_known=pos_known(inhood,:);
  unc_known=val_known(inhood,2);
  val_known=val_known(inhood,1);
  nknown=size(pos_known,1);
  
  % SET GLOBAL VARIANCE
  gvar=sum([V.par1]);
  
  
  % Data to Data matrix
  if any(strcmp(fieldnames(options),'d2d')); 
    K_sk=options.d2d(inhood,inhood);
  else
    K_sk=zeros(nknown,nknown);
    d=zeros(nknown,nknown);
    for i=1:nknown;
      for j=1:nknown;
        d(i,j)=edist(pos_known(i,:),pos_known(j,:));
      end
    end
    K_sk=gvar-semivar_synth(V,d);
  end
  % APPLY GAUSSIAN DATA UNCERTAINTY
  for i=1:nknown
    K_sk(i,i)=K_sk(i,i)+unc_known(i);
  end
    
  
  % Data to Unknown matrix
  if any(strcmp(fieldnames(options),'d2u')); 
    k_sk=options.d2u(inhood,:);
  else
    k_sk=zeros(nknown,1);
    d=zeros(nknown,1);
    for i=1:nknown;
      d(i)=edist(pos_known(i,:),pos_est(1,:));      
    end
    k_sk=gvar-semivar_synth(V,d);
  end
  lambda_sk = inv(K_sk)*k_sk;
  
  d_est = (val_known' - val_0)*lambda_sk(:)+ val_0;
  d_var = gvar - k_sk'*lambda_sk;