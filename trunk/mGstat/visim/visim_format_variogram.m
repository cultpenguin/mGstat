% visim_format_variogram
%
% Call : 
%      [str2d,str1,str2,str3]=visim_format_variogram(V,comp);
%
function [str2d,str1,str2,str3]=visim_format_variogram(V,comp);
  
  if nargin<2
    comp=1;
  end
  
  Va=V.Va;

  if V.Va.nugget>0
      str1=sprintf(' %12.6f Nug(0)',V.Va.nugget);
      str2=str1;
      str3=str1;
  else  
      str1='';  
      str2='';  
      str3='';  
  end
  
  for i=1:Va.nst

      if ((i>1)|(V.Va.nugget>0))
        str1=[str1,' + '];
        str2=[str2,' + '];
    end        
      
    if Va.it(i)==1
      type='Sph';
    elseif Va.it(i)==2
      type='Exp';
    else 
      type='Gau';
    end
    
    if V.nz==1;
        % 2D
    end
    
    if comp==0,
      str2d=sprintf('%s %12.6f %s(%5.1f,%5.1f,%5.1f)',str1,Va.cc(i),type,Va.a_hmax(i),Va.a_hmin(i)./Va.a_hmax(i),V.Va.ang1);
      str1=sprintf('%s %12.6f %s(%5.1f)',str1,Va.cc(i),type,Va.a_hmax(i));
      str2=sprintf('%s %12.6f %s(%5.1f)',str2,Va.cc(i),type,Va.a_hmin(i));
      str3=sprintf('%s %12.6f %s(%5.1f)',str3,Va.cc(i),type,Va.a_vert(i));
    else
      str2d=sprintf('%s %16.10f %s(%5.3f,%5.3f,%5.3f)',str1,Va.cc(i),type,Va.a_hmax(i),Va.a_hmin(i)./Va.a_hmax(i),V.Va.ang1);    
      str1=sprintf('%s %16.10f %s(%5.3f)',str1,Va.cc(i),type,Va.a_hmax(i));
      str2=sprintf('%s %16.10f %s(%5.3f)',str2,Va.cc(i),type,Va.a_hmin(i));
      str3=sprintf('%s %16.10f %s(%5.3f)',str3,Va.cc(i),type,Va.a_vert(i));
    end
    
  end
  
