% krig_npoint : as 'krig' butfor multiple estimation position.
%
% [d_est,d_var,options]=krig_npoint(pos_known,val_known,pos_est,V,options);
%
% As krig, but allowing size(pos_known,1)>1
%
% See also : krig
% 
function [d_est,d_var,options]=krig_npoint(pos_known,val_known,pos_est,V,options);

if nargin<5
  options.null=0;
end

d2d=[];
d2u=[];
ndata=size(pos_known,1);

n_est=size(pos_est,1);

if ischar(V)
  V=deformat_variogram(V);
end
%gvar=sum([V.par1]);


if iscell(V)
    options.noprecalc_d2d=1;
end

%% %% %% BUG BUG IN SETTUP ING d2d table!!!

if isfield(options,'d2d')
    d2d=options.d2d;
elseif ~isfield(options,'noprecalc_d2d')
    mgstat_verbose(sprintf('%s : precalculating data2data covariance matrix',mfilename),-1)
    options.d2d=precal_cov(pos_known,pos_known,V,options);
end

% 
if isfield(options,'d2u')
  d2u=options.d2u;
elseif isfield(options,'precalc_d2u')
    if options.precalc_d2u==1;
    mgstat_verbose(sprintf('%s : precalculating data2unknown covariance matrix',mfilename),-1)
    for j=1:size(pos_est,1)
        if (j/500)==round(j/500), 
            progress_txt(j,n_est,sprintf('%s : precal d2u',mfilename));
        end
        d2u(:,j)=precal_cov(pos_est(j,:),pos_known,V,options);
    end
    options.d2u=d2u;
    end
end
d_est=zeros(n_est,1);
d_var=zeros(n_est,1);


%options=rmfield(options,'d2d');
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
    if (i/100)==round(i/100), 
%    if (i/5)==round(i/5), 
      progress_txt(i,n_est,sprintf('%s : kriging',mfilename));
    end
    % SOMETHING WRONG WHEN USING 1D and options.d2d
    
    if iscell(V)
        [d_est(i),d_var(i)]=krig(pos_known,val_known,pos_est(i,:),V{i},options);
    else
        [d_est(i),d_var(i)]=krig(pos_known,val_known,pos_est(i,:),V,options);
    end
 end
end