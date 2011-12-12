% sgems_write_xml : write XML formatted SGEMS parameter file
%
% Call : 
%   filename=sgems_write_xml(XML,filename);
%  
function filename=sgems_write_xml(XML,filename);

if nargin==0
    help(mfilename)
    return
end

if nargin<2
    filename='sgems.par';
end


if ~isstruct(XML)
    mgstat_verbose(sprintf('%s : First input must an XML structure',mfilename),-1);
    mgstat_verbose(sprintf('%s : as read using sgems_read_selma for more',mfilename),-1);
    help(mfilename)
    return
end


mgstat_verbose(sprintf('%s : writing %s',mfilename,filename),1);

fid=fopen(filename,'w');

lev=0;
%fprintf(fid,'%s\n','<parameters>');
write_xml_structure(fid,XML,lev);
%fprintf(fid,'%s\n','</parameters>');

fclose(fid);



function write_xml_structure(fid,xml_struc,lev);


ntab=4;

fn=fieldnames(xml_struc);

for i=1:length(fn)
    istruct(i)=isstruct(xml_struc.(fn{i}));
    ichar(i)=ischar(xml_struc.(fn{i}));
end

%sum(istruct)
%if sum(istruct)==0
%    closed_tag=1;
%else
%    closed_tag=0;
%end


%% if CLOSED TAG AND NO SUB STRUC

%% IF NONCLOSED TAG AND SUB STRUC

% NO SUB STRUC
%if sum(istruct)==0
%    % NO SUB STRUCTS%
%
%    %disp('NO')
%    %fprintf(fid,'TEST\n');
%
%else


    for i=find(istruct)
        
        fname=fn{i};
        
        
        % FIND ANY ENTRIES FOR THIS STRUC
        fn_sub=fieldnames(xml_struc.(fn{i}));
        ichar_sub=[];
        istruct_sub=[];
        for j=1:length(fn_sub)
            istruct_sub(j)=isstruct(xml_struc.(fname).(fn_sub{j}));
            ichar_sub(j)=ischar(xml_struc.(fname).(fn_sub{j}));
        end
               
        if (sum(istruct_sub))==0
            closed_tag=1;
        else
            closed_tag=0;
        end
        
        ii=find(istruct_sub==0);
        clear tag_name;
        for k=ii;
            tag_name{k}=fn_sub{k};
            tag_value{k}=xml_struc.(fname).(fn_sub{k});
        end
        if length(ii)==0
            write_xml_line(fid,fname,[],[],lev,closed_tag);
        else
            write_xml_line(fid,fname,tag_name,tag_value,lev,closed_tag);
        end
        write_xml_structure(fid,xml_struc.(fn{i}),lev+1);
     
        if closed_tag==0;
            for j=1:(ntab*(lev)); fprintf(fid,'%s',' ');  end
            fprintf(fid,'</%s>\n',fname);
        end
        
    end


function write_xml_line(fid,name,tag_name,tag_value,lev,closed_tag);
ntab=4;
if isempty(tag_name)
    for j=1:(ntab*lev); fprintf(fid,'%s',' ');  end
    fprintf(fid,'<%s>\n',name);   
else
    for j=1:(ntab*lev); fprintf(fid,'%s',' ');  end
    fprintf(fid,'<%s',name);
    for i=1:length(tag_name);
        
         if isnumeric(tag_value{i})
             if (tag_value{i}==round(tag_value{i}));
                 tag_value_string=sprintf(' %d',tag_value{i});
             else
                 tag_value_string=sprintf(' %g',tag_value{i});
             end
         else
             tag_value_string=tag_value{i};
         end
         %if ~isempty(tag_name{i})
             txt_line=sprintf(' %s="%s"',tag_name{i},strip_space(tag_value_string,1));
             fprintf(fid,'%s',txt_line);
             %fprintf(fid,' %s="%s"',tag_name{i},strip_space(tag_value_string,1));
         %else
         %    disp(txt_line);
         %end
    end
    if closed_tag==1
        fprintf(fid,' />\n');
    else
        fprintf(fid,'>\n');
    end
    
end    
