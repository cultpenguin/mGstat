% deformat_variogram : convert gstat variogram line into matlab structure
%
% See also : format_variogram
%
% TMH /2004
%

function V=deformat_variogram(txt);

  
  txt=regexprep(txt,'\<;','');
  
  % HERE IS A BUG WHEN SOMETHING LIKE 'e+24 is used!!!
  fp=regexp(txt,'\+');
  
 
  nvar=length(fp)+1;
  mgstat_verbose(sprintf('Found %d variograms',nvar),10)  

  if  nvar==1,
    ifp_array=[0];
  else
    ifp_array=[0 fp];
  end
  ivar=0;  
  for ifp=ifp_array;
    ivar=ivar+1;
    
    if nvar==1,
      vartxt=txt;
    else
      if ifp==0,
        vartxt=txt(1:fp(1)-1);
      elseif ifp==fp 
        vartxt=txt(ifp+1:length(txt));
      else
        mgstat_verbose('MORE THAN TWO VARIOGRAMS NOT IMPLEMENTED YET',0)
      end
    end
    
    vartxt=strip_space(vartxt);
    mgstat_verbose(sprintf('V%d :  %s',ivar,vartxt),11)
    
    sp=find(vartxt==' ');
    lb=find(vartxt=='(');
    rb=find(vartxt==')');
    
    par1=vartxt(1:sp-1);
    par2=vartxt(lb+1:rb-1);
    type=strip_space(vartxt(sp+1:lb-1));
    
    if ~isempty(str2num(par1)), par1=str2num(par1); end
    if ~isempty(str2num(par2)), par2=str2num(par2); end
    
    if isempty(par2), par2=[];end
    
    
    V(ivar).par1=par1;
    V(ivar).par2=par2;
    V(ivar).type=type;
    
  end