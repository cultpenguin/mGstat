i=0;
i=i+1;f{i}='*.m';
i=i+1;f{i}='visim/*.m';
i=i+1;f{i}='sgems/*.m';
i=i+1;f{i}='snesim/*.m';
i=i+1;f{i}='misc/*.m';
i=i+1;f{i}='fast/*.m';


for ff=1:length(f)
    
    fid=fopen(sprintf('mgstat_function_%s.xml',fileparts(f{ff})),'w');

    
    FILES=dir(f{ff});
    
    for i=1:length(FILES)
      [p,name,ext]=fileparts(FILES(i).name);
      disp(name)
      h=help(name);
      
      fprintf(fid,'<sect2 id=\"%s\"><title>%s</title>\n',name,name);
      fprintf(fid,'<para><programlisting><![CDATA[%s]]></programlisting></para>\n',h);
      fprintf(fid,'</sect2>\n\n');
      
    end


    fclose(fid);

    
end
  
