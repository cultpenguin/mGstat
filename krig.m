% krig : Simple/Ordinar/Trend Kriging
%
% Call :
% [d_est,d_var,lambda_sk,K_dd,k_du,inhood]=krig(pos_known,val_known,pos_est,V,options);
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

function [d_est,d_var,lambda,K,k,inhood]=krig(pos_known,val_known,pos_est,V,options);

  if isstr(V),
    V=deformat_variogram(V);
  end 

  if nargin<5
    options.null=0;
  end
  
  if any(strcmp(fieldnames(options),'pos_weight')); 
  	for i=1:size(pos_known,2);
		pos_known(:,i)=pos_known(:,i).*options.pos_weight(i);
		pos_est(:,i)=pos_est(:,i).*options.pos_weight(i);
	end  
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

  
  
  % DETERMINE TYPE OF KRIGING
  if  any(strcmp(fieldnames(options),'trend'))
    ktype=2; % Ktrend
    mgstat_verbose('Kriging with a trend',20);
  elseif  any(strcmp(fieldnames(options),'mean'))
    ktype=0; % SK
    mgstat_verbose('Simple Kriging',20);
  else 
    ktype=1; % OK
    mgstat_verbose('Ordinary Kriging',20);
  end

  nknown=size(pos_known,1);
  ndim=size(pos_known,2);
  n_est=size(pos_est,1);
  if n_est~=1, 
    mgstat_verbose('Warning : you called krig with more than one',100)
    mgstat_verbose('unknown data location',100)
    mgstat_verbose('--- Calling krig_npoint instead',100)
    [d_est,d_var,d2d,d2u]=krig_npoint(pos_known,val_known,pos_est,V,options);
    lambda_sk=[];K=[];k=[];inhood=[];
    return
  end
      
  % SELECT NEIGHBORHOOD
  [inhood,order_list]=nhood(pos_known,pos_est,options);
  
  pos_known=pos_known(inhood,:);
  unc_known=val_known(inhood,2);
  val_known=val_known(inhood,1);
  nknown=size(pos_known,1);
  
  % SET GLOBAL VARIANCE
  gvar=sum([V.par1]);
  
  transform=V(1).par2;
    
  if ktype==0
    K=zeros(nknown,nknown);
    k=zeros(nknown,1);
  elseif ktype==1
    K=zeros(nknown+1,nknown+1);
    k=zeros(nknown+1,1);
  else % KTREND
    K=zeros(nknown+ndim,nknown+ndim);
    k=zeros(nknown+ndim,1);
  end
  
  % Data to Data matrix
  if any(strcmp(fieldnames(options),'d2d')); 
    K=options.d2d(inhood,inhood);
  else
    K=zeros(nknown,nknown);
    d=zeros(nknown,nknown);
    for i=1:nknown;
      for j=1:nknown;
        d(i,j)=edist(pos_known(i,:),pos_known(j,:),transform);
      end
    end
    K=gvar-semivar_synth(V,d);
  end
  % APPLY GAUSSIAN DATA UNCERTAINTY
  for i=1:nknown
    K(i,i)=K(i,i)+unc_known(i);
  end
  
  % Data to Unknown matrix
  if any(strcmp(fieldnames(options),'d2u')); 
    k=options.d2u(inhood,:);
  else
    k=zeros(nknown,1);
    d=zeros(nknown,1);
    for i=1:nknown;
      d(i)=edist(pos_known(i,:),pos_est(1,:),transform);      
    end
    k=gvar-semivar_synth(V,d);
  end

  % ADJUST K and k for KRIGING METHODS
  if ktype==1
    K(nknown+1,1:nknown)=ones(1,nknown);
    K(1:nknown,nknown+1)=ones(nknown,1);
    k(nknown+1)=1;
  elseif ktype==2
    
	if isfield(options,'polytrend')==0
	   polytrend=1;
	else
	   polytrend=options.polytrend;
	end
        
	if length(polytrend)==1,
          polytrend=ones(1,ndim).*polytrend;
        end
        
        
        %polytrend=4;

        K(nknown+1,1:nknown)=ones(size(pos_known(:,1),1),1);
        K(1:nknown,nknown+1)=ones(size(pos_known(:,1),1),1);
        k(nknown+1)=1;
                   
        ik=1;
        for id=1:ndim
          for it=1:1:polytrend(id)
            ik=ik+1;
            K(nknown+ik,1:nknown)=[pos_known(:,id)'].^(it);
            K(1:nknown,nknown+ik)=[pos_known(:,id)].^(it);
            k(nknown+ik)=[pos_est(id)].^(it);
          end
	end
  end  

  % SOLVE THE LINEAR SYSTEM
  
  lambda = inv(K)*k;

  if ktype==0
    d_est = (val_known' - val_0)*lambda(:)+ val_0;
  elseif ktype==1
    d_est =  val_known'*lambda(1:nknown);
  elseif ktype==2
    d_est = val_known'*lambda(1:nknown);
  else
  end
  d_var = gvar - k'*lambda;
