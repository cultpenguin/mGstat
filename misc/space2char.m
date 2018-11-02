% space2char : replace oen character with another in string
%
% txtout=space2char(txt,charout,charin);
%
% Example : 
%    txt='Hello nice world';
%    space2char(txt)
%            ans = Hello_nice_world
%    space2char(txt,'+')
%            ans = Hello+nice+world
%    space2char(txt,'+','l')
%            ans = He++o nice wor+d
%
function txt=space2char(txt,charout,charin)
    if nargin<3
        charin=' ';
    end
    if nargin<2
        charout='_';
    end
    if nargin==0
        help space2char
        return
    end
    
    txt=regexprep(txt,charin,charout);

    