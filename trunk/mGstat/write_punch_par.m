% write_punch_par(filename,timefile,velfile,fxs,fys,fzs,nx,ny,nz,x0,y0,z0,h,reverse,maxoff);
% Purpose : WRITES OUT PAR-FILE FOR USE WITH 'PUNCH' (John Hole)
%
% CALL write_punch_par(filename,timefile,velfile,fxs,fys,fzs,nx,ny,nz,x0,y0,z0,h,reverse,maxoff);
%  filename [string] : Name of par-file
%  timefile [string] : Name of output-time file
%  velfile  [string] : Name of input velocity file
%  fxs      [scalar] :
%  fys      [scalar] :
%  fzs      [scalar] :
%  nx       [scalar] :
%  ny       [scalar] :
%  nz       [scalar] :
%  x0       [scalar] :
%  y0       [scalar] :
%  z0       [scalar] :
%  h        [scalar] :
%  reverse  [scalar] :
%  maxxoff  [scalar] : Maximum offset
% 
% TMH 09/1999
%

function write_punch_par(filename,timefile,velfile,fxs,fys,fzs,nx,ny,nz,x0,y0,z0,h,reverse,maxoff);

if nargin==0,
  filename='punch.par';
  fxs=.1;
  fys=0.;
  fzs=100.;
  nx=301;
  ny=1;
  nz=1601;
  x0=0.;
  y0=0.;
  z0=0.;
  h=.1;
  timefile='time100.2d';
  velfile='vel.2d';
  reverse=0;
  maxoff=160.;   
end

fid=fopen(filename,'w');

%fprintf(fid,'fxs=%3.1f\n',fxs);
%fprintf(fid,'fys=%3.1f\n',fys);
%fprintf(fid,'fzs=%3.1f\n',fzs);
%fprintf(fid,'floatsrc=1\n');
fprintf(fid,'fxs=%f\n',fxs);
fprintf(fid,'fys=%f\n',fys);
fprintf(fid,'fzs=%f\n',fzs);
fprintf(fid,'nx=%d\n',nx);
fprintf(fid,'ny=%d\n',ny);
fprintf(fid,'nz=%d\n',nz);
fprintf(fid,'x0=%f\n',x0);
fprintf(fid,'y0=%f\n',y0);
fprintf(fid,'z0=%f\n',z0);
fprintf(fid,'h=%f\n',h);
fprintf(fid,'timefile=%s\n',timefile);
fprintf(fid,'velfile=%s\n',velfile);
fprintf(fid,'reverse=%d\n',reverse);
fprintf(fid,'maxoff=%4.1f\n',maxoff);
fclose(fid);


