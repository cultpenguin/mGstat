% FUNCTION : [fxs,fys,fzs,nx,ny,nz,x0,y0,z0,h,timefile,velfile,reverse,maxoff]=read_punch_par(filename); 
% Purpose : Reads PAR file from PUNCH program (HOLE PROGRAM)
% 
% TMH 09/1999;
%
%
function [fxs,fys,fzs,nx,ny,nz,x0,y0,z0,h,timefile,velfile,reverse,maxoff]=read_punch_par(filename);
fid=fopen(filename);
 n=0;
 while 1
   n=n+1;
   line = fgetl(fid);
   if ~isstr(line), break, end
   sep=find(line=='=');
   l=length(line);
   %disp([num2str(n),line(1:sep),'  ',line(sep+1:l)]);
   if n==1, fxs=str2num(line(sep+1:l)); end;
   if n==2, fys=str2num(line(sep+1:l)); end;
   if n==3, fzs=str2num(line(sep+1:l)); end;
   if n==4, nx=str2num(line(sep+1:l)); end;
   if n==5, ny=str2num(line(sep+1:l)); end;
   if n==6, nz=str2num(line(sep+1:l)); end;
   if n==7, x0=str2num(line(sep+1:l)); end;
   if n==8, y0=str2num(line(sep+1:l)); end;
   if n==9, z0=str2num(line(sep+1:l)); end;
   if n==10, h=str2num(line(sep+1:l)); end;
   if n==11, timefile=line(sep+1:l); end;
   if n==12, velfile=line(sep+1:l); end;
   if n==13, reverse=str2num(line(sep+1:l)); end;
   if n==14, maxoff=str2num(line(sep+1:l)); end;
 end
 fclose(fid);
