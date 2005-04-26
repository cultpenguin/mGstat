% strip_space : strip leading/tailing spaces from string
%
% CALL :
%   txt=strip_space(txt);
%
% EX :
%  a='    Hei Ho Here We Go      ';
% ['''',strip_space(a),'''']
% ans = 
% 'Hello World'
%
% TMH / 2004
%
function txt=strip_space(txt);

  % leading space 
  txt=regexprep(txt,'\< ','');
  
  % trailing space
  txt=regexprep(txt,' \>','');  
  