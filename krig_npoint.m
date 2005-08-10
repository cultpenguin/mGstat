% krig_npoint : as 'krig' butfor multiple estimation position.
%
% [d_est,d_var,d2d,d2u]=krig_npoint(pos_known,val_known,pos_est,V,options);
%
% As krig, but allowing size(pos_known,1)>1
%
% See also : krig
% 
function [d_est,d_var,d2d,d2u]=krig_npoint(pos_known,val_known,pos_est,V,options);

if nargin<5
  options.null=0;
end

d2d=[];
d2u=[];
ndata=size(pos_known,1);

n_est=size(pos_est,1);


if isstr(V)
  V=deformat_variogram(V);
end
gvar=sum([V.par1]);

if isfield(options,'d2d')
  d2d=options.d2d;
elseif ~isfield(options,'noprecalc_d2d')
  % Precalculte Data to data Covariance matrix
  % unless explicitly chosen not to in 'options'
  d2d=zeros(ndata,ndata);
  d=zeros(ndata,ndata);
  mgstat_verbose([mfilename,' : Setting up d2d covariance']);
  for i=1:ndata;
    if (i/100)==round(i/100), 
      mgstat_verbose(sprintf('Setting up d2d covariance %d/%d',i,ndata));
    end
    for j=i:ndata;
      d(i,j)=edist(pos_known(i,:),pos_known(j,:));
      d(j,i)=d(i,j);
      %d2d(i,j)=gvar-semivar_synth(V,d(i,j));    
      %d2d(j,i)=d2d(i,j);
    end
  end
  d2d=gvar-semivar_synth(V,d);    
end

if isfield(options,'d2u')
  d2u=options.d2u;
elseif isfield(options,'precalc_d2u')
  % Precalculte Data to data Covariance matrix
  % ONLY IF chosen in 'options'
  n_est=size(pos_est,1);
  d2u=zeros(ndata,n_est);
  d=zeros(ndata,n_est);
  mgstat_verbose([mfilename,' : Setting up d2u covariance']);
  for i=1:ndata;
    if (i/100)==round(i/100), 
      mgstat_verbose(sprintf('Setting up d2u covariance %d/%d',i,ndata));
    end
    for j=1:n_est;
      d(i,j)=edist(pos_known(i,:),pos_est(j,:));
    end
  end
  d2u=gvar-semivar_synth(V,d);    
  options.d2u=d2u;
end

d_est=zeros(n_est,1);
d_var=zeros(n_est,1);

if isfield(options,'d2u');
  % MAKE USE OF PRECALCULATED DATA 2 UNKNOWN
  for i=1:n_est
    if (i/100)==round(i/100), 
      mgstat_verbose(sprintf('%s : kriging : %d/%d',mfilename,i,n_est));
    end    
    options.d2u=d2u(:,i);
    [d_est(i),d_var(i)]=krig(pos_known,val_known,pos_est(i,:),V,options);
  end
else
  for i=1:n_est
    if (i/100)==round(i/100), 
      mgstat_verbose(sprintf('%s : kriging : %d/%d',mfilename,i,n_est));
    end    
    [d_est(i),d_var(i)]=krig(pos_known,val_known,pos_est(i,:),V,options);
  end
end