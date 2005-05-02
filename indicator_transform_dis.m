% indicator_transform_dis : transform discrete data into indicator
%
% CALL :
%
% [id,lev]=indicator_transform_dis(d,ident)
% 
% [d] : data
% [ient] : Transform data into a binary discrete data, such that Prob(zi=ident(i))
%         if not specified level is chosen all unique4 discrete
%         identifiers are chosen.
%
function [id,lev]=indicator_transform_dis(d,ident)
  
  if nargin==1
    ident=unique(d);
  end

  
  nl=length(ident);
  nd=length(d);
  
  id=zeros(nd,nl);
  
  for il=1:nl
    ind=find(d==ident(il));
    id(ind,il)=1;
  end

  
  subplot(nl+1,1,1)
  bar(d);title('all data')
  for i=1:nl
    subplot(nl+1,1,i+1)
    bar(id(:,i));title(num2str(ident(i)))
  end
  
  