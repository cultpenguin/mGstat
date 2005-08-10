function [inhood,order_list]=nhood(pos_known,pos_est,options);
  
  if ~isfield(options,'max')
    options.max=40;
  end
    
  
  nknown=size(pos_known,1);
  ndim=size(pos_known,2);
  
  
  
  % FIRST FIND THE CLOSEST DATA
  % MAKE A MORE GENERAL SUBROUTINE HERE !!!!
  d=zeros(nknown,1);
  for ir=1:nknown
    d(ir)=edist(pos_est,pos_known(ir,:));
  end
  id=[1:nknown]';
  order_list=sortrows([id,d],[2]);
  order_list=order_list(:,1);
  
  % SELECT NEIGHBORHOOD
  usemax=min(options.max,nknown);
  inhood=order_list(1:usemax);