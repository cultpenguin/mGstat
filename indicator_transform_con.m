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
function [id,lev]=indicator_transform_con(d,lev)
  
  
  nl=length(lev);
  nd=length(d);
  
  id=zeros(nd,nl);
  
  for il=1:nl
    ind=find(d<lev(il));
    id(ind,il)=1;
  end
  
