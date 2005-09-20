% indicator_transform_con : transform continous data into indicator
%
% CALL :
%
% [id,lev]=indicator_transform_con(d,lev)
% 
% [d] : data
% [lev] : indicator transform of list lev#s : Prob(zi<lev(i))
%         if not specified level is chosen to match qantiles
%         .1,.2,...,.9
%
function [id,lev,sid]=indicator_transform_con(d,lev)

  dnan=find(isnan(d));
  
  if nargin==2
    if length(lev)==1;
      nbins=lev;
    end
  end
  
  if ((nargin==1)|exist('nbins'))
     sd=sort(d(find(~isnan(d))));
     if ~exist('nbins')
       nbins=10;
     end
     lev=interp1([1:1:length(sd)]./length(sd),sd,linspace(1/nbins,1,nbins));
  end
  
  
  
  
  
  nl=length(lev);
  nd=length(d);
  
  id=zeros(nd,nl);
  
  for il=1:nl
    ind=find(d<=(lev(il)+1e-9));
    id(ind,il)=1;
    id(dnan,il)=NaN;
  end
  
  if nargout==3;
    sid=sum(id')';
  end
  