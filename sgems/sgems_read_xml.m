% sgems_read_xml
function chars=sgems_read_xml(filename);

fid=fopen(filename,'r');

chars=fread(fid,'char');

fclose(fid);



xl=find(chars==60);
xr=find(chars==62);
xslash=find(chars==47);

for i=1:length(xl)
    if chars(xl(i)+1)==47;
        xl_slash(i)=1;
    else
        xl_slash(i)=0;
    end

    if chars(xr(i)-1)==47;
        xr_slash(i)=1;
    else
        xr_slash(i)=0;
    end
end



for ientry=1:length(xl);
    
    cc=chars(xl(ientry):xr(ientry))'    ;
    p=char(cc);
    p=regexprep(p,' =','=');
    p=regexprep(p,'= ','=');
    p=regexprep(p,char(10),' '); % remove change
    p=regexprep(p,char(13),' '); % remove change
    
    
    p=regexprep(p,char(10),'-');
    
%     if xr_slash(ientry)==1
%         STR=(p(2:length(p)-2));
%     else
%         STR=(p(2:length(p)-1));
%     end
% 
%     if xl_slash(ientry)==1
%         STR=(p(3:length(p)));
%     else
%         STR=(p(2:length(p)));
%     end
STR=p;

% 

disp(sprintf('%03d : %s',ientry,STR))
end
keyboard


%for ic=1:length(char);
%    if 
