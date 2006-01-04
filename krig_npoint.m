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
  d2d=precal_cov(pos_known,pos_known,V,options);
  options.d2d=d2d;
end

if isfield(options,'d2u')
  d2u=options.d2u;
elseif isfield(options,'precalc_d2u')
  d2u=precal_cov(pos_known,pos_est,V);
  options.d2u=d2u;
end


d_est=zeros(n_est,1);
d_var=zeros(n_est,1);

if isfield(options,'d2u');
  % MAKE USE OF PRECALCULATED DATA 2 UNKNOWN
  for i=1:n_est
    if (i/500)==round(i/500), 
      progress_txt(i,n_est,sprintf('%s : kriging',mfilename));
    end    
    options.d2u=d2u(:,i);
    [d_est(i),d_var(i)]=krig(pos_known,val_known,pos_est(i,:),V,options);
  end
else
  for i=1:n_est
    if (i/50)==round(i/50), 
      progress_txt(i,n_est,sprintf('%s : kriging',mfilename));
    end    
    [d_est(i),d_var(i)]=krig(pos_known,val_known,pos_est(i,:),V,options);
  end
end