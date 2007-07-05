% visim_format_variogram
%
% Call : 
%      [str1,str2]=visim_format_variogram(V,comp);
%
function [str1,str2]=visim_format_variogram(V,comp);
  
  if nargin<2
    comp=1;
  end
  
  Va=V.Va;
  
  str='';  
  
  for i=1:Va.nst

    
    if Va.it(i)==1
      type='Sph';
    elseif Va.it(i)==2
      type='Exp';
    else 
      type='Gau';
    end
    
    if comp==0,
      str1=sprintf('%s %8.3f %s(%5.1f)',str,Va.cc(i),type,Va.a_hmax);
      str2=sprintf('%s %8.3f %s(%5.1f)',str,Va.cc(i),type,Va.a_hmin);
    else
      str1=sprintf('%s %6.4g %s(%5.3f)',str,Va.cc(i),type,Va.a_hmax);
      str2=sprintf('%s %6.4g %s(%5.3f)',str,Va.cc(i),type,Va.a_hmin);
    end
    
  end
  
