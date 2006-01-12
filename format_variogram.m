% format_variogram : Convert matlab style Variogram to Gstat style
%
% Call :
%   txt=format_variogram(V);
%
function txt=format_variogram(V,short);
  
  if nargin==1
    short=0;
  end
  
  txt=[''];

  for i=1:length(V)
    if i>1, txt=[txt,' + '];end
    
    % CHECK IF ANISTROPY IS USED
    if length(V(i).par2)>1
      % disp('anisotropy')
      % make sure to add extra space around negative values (MINUS
      % signs), but NOT for example on '1e-6'
      range=regexprep( strip_space(num2str(V(i).par2)) , ' -','  -' );
      range=regexprep( range, ' ',',' );
    else
      range=num2str(V(i).par2);
    end

    if short==0 
      txt=[txt,sprintf('%11.8f %s(%s)',V(i).par1,V(i).type,range)];
    else
      txt=[txt,sprintf('%4.1f %s(%s)',V(i).par1,V(i).type,range)];
    end

%    OLD CODE BEFORE ANISOTROPY HANDLING
%    if short==0 
%      txt=[txt,sprintf('%11.8f %s(%11.8f)',V(i).par1,V(i).type,V(i).par2)];
%    else
%      txt=[txt,sprintf('%3.1f %s(%3.1f)',V(i).par1,V(i).type,V(i).par2)];
%    end
  end
  