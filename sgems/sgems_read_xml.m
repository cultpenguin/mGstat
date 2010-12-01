% sgems_read_xml
function [XML,xml_entry,S]=sgems_read_xml(filename);

mgstat_verbose(sprintf('%s : reading %s',mfilename,filename),0);

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

n_entries=length(xl);

%% FIND EACH ENTRY IN XML FILE
for ientry=1:n_entries;
    
    cc=chars(xl(ientry):xr(ientry))'    ;
    p=char(cc);
    p=regexprep(p,' =','=');
    p=regexprep(p,'= ','=');
    p=regexprep(p,char(10),' '); % LINE FEED, NEW LINE
    p=regexprep(p,char(13),' '); % CARRIAGE RETURN
    mgstat_verbose(sprintf('%s : entry : %s',mfilename,p),3);
    
    xml_entry{ientry}=p;
end

% FIND LEVEL OF EACH ENTRY
lev=1;
for i=1:n_entries
    
    S{i}=parse_xml_entry(xml_entry{i});

    if S{i}.end_tag==1;
        lev=lev-1;
        try
            mgstat_verbose(sprintf('%s : XML level = %d (%s)',mfilename,lev,struct_level{lev}),1);
        end
    else

        
        
        if (S{i}.end_tag==0)&(S{i}.closed_tag==0)
            try
              struct_level{lev}=S{i}.struct_name;
              mgstat_verbose(sprintf('%s : XML level = %d (%s)',mfilename,lev,struct_level{lev}),2);
            catch
                keyboard
            end
        end


        try
            
            struct_name=S{i}.struct_name;
            if lev==1;           
                XML.(struct_level{1})=S{i}.(struct_name);
            elseif lev==2;
                XML.(struct_level{1}).(struct_name)=S{i}.(struct_name);
            elseif lev==3;
                XML.(struct_level{1}).(struct_level{2}).(struct_name)=S{i}.(struct_name);
            elseif lev==4;
                XML.(struct_level{1}).(struct_level{2}).(struct_level{3}).(struct_name)=S{i}.(struct_name);
            elseif lev==5;
                XML.(struct_level{1}).(struct_level{2}).(struct_level{3}).(struct_level{4}).(struct_name)=S{i}.(struct_name);
            else
                mgstat_verbose(sprintf('%s : Only 5 nested levels are supported',mfilename),10)
            end
        catch
            keyboard
        end
        
        if (S{i}.end_tag==0)&(S{i}.closed_tag==0)
            lev=lev+1;
        end
    end
    
    
end

%XML=XML.(struct_level{1});


%%
function S=parse_xml_entry(xml_string)

% FIX LEADING SPACE BEFORE '=', such as 'cdf_type ="constant"' 
xml_string=regexprep(xml_string, '\s=','=');

% FIND LEADING TAG
ispace=findstr(xml_string,' ');
ieq=findstr(xml_string,'=');

if strfind(xml_string(length(xml_string)-1),'/')
    closed_tag=1;
else
    closed_tag=0;
end
end_tag=0;
if isempty(ispace)
    struct_name=xml_string(2:(length(xml_string)-1));
    if strfind(struct_name(1),'/')
        struct_name=struct_name(2:length(struct_name));
        end_tag=1;
    end
    S.(struct_name)=[];
    S.end_tag=end_tag;
    S.closed_tag=closed_tag;
    S.struct_name=struct_name;
    return
end
struct_name=xml_string(2:ispace(1)-1);
mgstat_verbose(sprintf('%s :   -- %s (%s)',mfilename,struct_name,xml_string),1);
names= regexp(xml_string, '\w*\=','match');
vals = regexp(xml_string, '".*"','match');
vals = regexp(xml_string, '"[^"]*"','match');
for i=1:length(names);
    try
        str=strrep(names{i},'=','');
        val=strrep(vals{i},'"','');
        if exist(val,'file')~=2 
            % ABOVE LINE TO PREVENT FAILURR CALLING 'sgsim.m' WHEN 
            % TRYING TO USE STR2NUM('sgsim')
        if ~isempty(str2num(val))
            val=str2num(val);
        end
        end
        %if (isstr(val)&~isempty(val))
        %    mgstat_verbose(sprintf('%s = %s',str,val),1);           
        %elseif (~isempty(val)&isstr(str))
        %    mgstat_verbose(sprintf('%s = %g',str,val),1);
        %end
        S.(struct_name).(str)=val;
        S.end_tag=end_tag;
        S.closed_tag=closed_tag;
        S.struct_name=struct_name;
    
    catch
        keyboard
    end
end
