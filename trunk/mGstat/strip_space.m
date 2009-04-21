% strip_space : strip leading/tailing spaces from string
%
% CALL :
%   txt=strip_space(txt,type);
%
%   txt[string]
%   type[integer] : [0] strip leading and trailing space (default);
%   type[integer] : [1] strip leading space;
%   type[integer] : [2] strip trailing space;
%
%
% EX :
%  a='    Hei Ho Here We Go      ';
% ['''',strip_space(a),'''']
% ans = 
% 'Hello World'
%
%% strip leading space
% ['''',strip_space(a,1),'''']
%% strip trailing space
% ['''',strip_space(a,2),'''']
% 

% TMH / 2004
%
function txt=strip_space(txt,type);
  if nargin==1
      type=0;
  end

  % leading space
  if ((type==0)|(type==1))
  txt=regexprep(txt,'\< ','');
  end
  % trailing space
  if ((type==0)|(type==2))
  txt=regexprep(txt,' \>','');  
  end