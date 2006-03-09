f{1}=dir('*.m')
f{2}=dir('visim/*.m')

fid=fopen('mgstat_function.xml','w');

for ff=1:length(f)

    for i=1:length(f{ff})
      [p,name,ext]=fileparts(f{ff}(i).name);
      disp(name)
      h=help(name);
      
      fprintf(fid,'<sect1 id=\"%s\"><title>%s</title>\n',name,name);
      fprintf(fid,'<para><programlisting><![CDATA[%s]]></programlisting></para>\n',h);
      fprintf(fid,'</sect1>\n\n');
      
    end
    
  end

fclose(fid);
  