% nhood : Neighborhood selection
%
%
% TMH/2005
%
function [inhood,order_list]=nhood(pos_known,pos_est,options);
  
  if ~isfield(options,'max')
    options.max=40;
  end
  
  
  
  nknown=size(pos_known,1);
  ndim=size(pos_known,2);
  usemax=min(options.max,nknown);
  
  
  method=2;
  if isfield(options,'d2u');
    method=1;
  end
  
  if method==2;
    % CALCULATE DISTANCE
    % COMPUTATIONAL EXPENSIVE
    d=zeros(nknown,1);
    for ir=1:nknown
      d(ir)=edist(pos_est,pos_known(ir,:));
    end
    id=[1:nknown]';
    order_list=sortrows([id,d],[2]);
    order_list=order_list(:,1);
  else
    d=options.d2u;
    id=[1:nknown]';
    order_list=sortrows([id,d],[2]);
    order_list=flipud(order_list(:,1));    
    
  end
  
  % SELECT NEIGHBORHOOD
  inhood=order_list(1:usemax);