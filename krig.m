% krig_sk : Simple Kriging
%
% Call :
%  function [d_est,d_var,lambda_sk,K_dd,k_du]=krig(pos_known,val_known,pos_est,V,val_0);
%
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

function [d_est,d_var,lambda_sk,K_sk,k_sk]=krig_sk(pos_known,val_known,pos_est,V,val_0);

  if isstr(V),
    V=deformat_variogram(V);
  end 
  
  if nargin==4,
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
    mgstat_verbose('ERROR : CURRENTLY size(pos_est,1) must equal 1',0);
  end
  
    
  % SELECT NEIGHBORHOOD
  options.max=7;
  [inhood,order_list]=nhood(pos_known,pos_est,options);
 
  pos_known=pos_known(inhood,:);
  unc_known=val_known(inhood,2);
  val_known=val_known(inhood,1);
  nknown=size(pos_known,1);
  
  % SET GLOBAL VARIANCE
  gvar=sum([V.par1]);
  
  % Data to Data matrix
  K_sk=zeros(nknown,nknown);
  for i=1:nknown;
    for j=1:nknown;
      d=edist(pos_known(i,:),pos_known(j,:));
      K_sk(i,j)=gvar-semivar_synth(V,d);
      if i==j
        % APPLY UNCERTAINTY
        K_sk(i,j)=K_sk(i,j)+unc_known(i);
      end
    end
  end
  
  % Data to Unknown matrix
  k_sk=zeros(nknown,1);
  for i=1:nknown;
    d=edist(pos_known(i,:),pos_est(1,:));      
    k_sk(i)=gvar-semivar_synth(V,d);
  end
 
  lambda_sk = inv(K_sk)*k_sk;
  
  d_est = (val_known' - val_0)*lambda_sk(:)+ val_0;
  % d_var = gvar - k_sk'*inv(K_sk)*k_sk;
  d_var = gvar - k_sk'*lambda_sk;