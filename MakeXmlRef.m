f=dir('*.m')

fid=fopen('mgstat_function.xml','w');

for i=1:length(f)
  [p,name,ext]=fileparts(f(i).name);
  disp(name)
  h=help(name);
  
  fprintf(fid,'<sect1 id=\"%s\"><title>%s</title>\n',name,name);
  fprintf(fid,'<para><programlisting><![CDATA[%s]]></programlisting></para>\n',h);
  fprintf(fid,'</sect1>\n\n');
  
  
  
end

fclose(fid);
  