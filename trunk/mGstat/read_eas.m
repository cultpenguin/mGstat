% read_eas : reads an GEO EAS formatted file into Matlab.
%
% Call [data,header]=read_eas(filename);
%
% TMH (tmh@gfy.ku.dk)
%
function [data,header]=read_eas(filename);
   fid=fopen(filename,'r');
   txt_title=fgetl(fid);

   disp(txt_title);
   
   nc=str2num(fgetl(fid));
   

   
   for i=1:nc,
     header{i}=fgetl(fid);
   end

   
   i=0;
   while ~(feof(fid));
     i=i+1;
     if (i/1000)==round(i/1000),disp(sprintf('%d',i));end
     l=fgetl(fid);
     l_v= sscanf(l,'%f');
     data(i,:)=zeros(1,nc);
     data(i,1:length(l_v))= l_v(:)';
   end
   
   fclose(fid);

   
   