% strip_space : strip leading/tailing spaces from string
%
% TMH / 2004
%
function txt=strip_space(txt);

  % leading space 
  txt=regexprep(txt,'\< ','');
  
  % trailing space
  txt=regexprep(txt,' \>','');  
  