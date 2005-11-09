function [str1,str2]=visim_format_variogram(V);
  
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
    
    str1=sprintf('%s %5.1g %s(%5.1f)',str,Va.cc(i),type,Va.a_hmax);
    str2=sprintf('%s %5.1g %s(%5.1f)',str,Va.cc(i),type,Va.a_hmin);
    
    
  end
  