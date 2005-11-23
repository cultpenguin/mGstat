% read_eas : reads an GEO EAS formatted file into Matlab.
%
% Call [data,header]=read_eas(filename);
%
% TMH (tmh@gfy.ku.dk)
%
function [data,header,txtdata,txtheader]=read_eas(filename);
   fid=fopen(filename,'r');
   txt_title=fgetl(fid);

   %disp(txt_title);
   l=fgetl(fid);
   % next 3 lines to satisfy sisim.f
   if  isempty(str2num(l))
     l=fgetl(fid);
   end
   nc=str2num(l);
      
   for i=1:nc,
     header{i}=fgetl(fid);
   end
   header=regexprep(header,char(9),'');

   nvar=length(header);
   
   fpos_start=ftell(fid);
   
   use_alt=0;
   txtdata=[];
   txtheader=[];
   
   try
          
     data=fscanf(fid,'%f',[inf]);
     ndata=length(data)./length(header);
     data=reshape(data(:),nvar,ndata)';
     
   catch
     use_alt=1;
   end
   
   % If no data has been read, use alternate method
   if isempty(data), use_alt=1; end
   
   if use_alt==1,
     clear data
     disp('Trying to read data into cell structure')
     fseek(fid,fpos_start,'bof');
     i=0;
     while ~(feof(fid));
       i=i+1;
       if (i/1000)==round(i/1000),disp(sprintf('%d',i));end
       s=fgetl(fid);
       
       % Strip line into values seperated by space(s).
       l = {};
       while (length(s) > 0)
         [t,s] = strtok(s);
         l = {l{:}, t};
       end

%       disp(i)
       txtdata_header=[];
       h1=0;h2=0;
       for i2=1:min(length(l),nc)
         val=l{i2};
         try
           if (~isempty((str2num(val))))&(~strcmp(val,'i'))           
             val=str2num(val);
             data.(header{i2})(i)=val;
             
             h1=h1+1;data_header{h1}=header{i2};
           else           
             if ~isempty(val)
               txtdata.(header{i2}){i}=val;           
               h2=h2+1;txtdata_header{h2}=header{i2};
             else
               % disp(sprintf('data line %d pos %d: Empty Value',i,i2))
             end    
           end
         catch
           disp('READ ERROR')

         end
       end
       
%       if i==10000;
%         return
%       end
     end
     % convert data to normal eas matrix

     nh=length(data_header);
     nd=length(data.(header{1}));
     data_out=zeros(nd,nh);
     for i=1:nh;
         ndh=length(data.(data_header{i}));
         data_out(1:ndh,i)=data.(data_header{i})(1:ndh);
     end
     data=data_out;
     header=data_header;
     txtheader=txtdata_header;
     
     
     
   end
   
   
   
   fclose(fid);

   
   