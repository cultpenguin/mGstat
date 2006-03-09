% punch : calls punch (John Hole, eikonal)
%
% CALL : 
%   t=punch(Vel,x,y,z,S)
%
function t=punch(Vel,x,y,z,S)
  

  punch_bin='~/RESEARCH/PROGRAMMING/GSLIB/visim/visim_examples/punch';
  punch_bin='~/RESEARCH/PROGRAMMING/mGstat/bin/punch';
  
if exist(punch_bin)==0
	disp(sprintf('Could not locate PUNCH binary at %s',punch_bin));
  	disp('Exiting....')
	t=[];
	return 
end

  fvel='punch.vel';
  ftime='punch.time';
  fpunch='punch.par';
   
  write_bin('punch.vel',Vel(:));
  
  dx=x(2)-x(1);
  
  nx=length(x);
  ny=length(y);
  nz=length(z);
  
  fxs=S(1);
  fys=S(2);
  fzs=S(3);
  
  x0=x(1);
  y0=y(1);
  z0=z(1);
  
  reverse=1;
  maxoff=sqrt((max(x)-min(x)).^2+(max(y)-min(y)).^2+(max(z)-min(z)).^2);
  
  write_punch_par(fpunch,ftime,fvel,fxs,fys,fzs,nx,ny,nz,x0,y0,z0,dx,reverse,maxoff)
  
  [s,w]=unix(sprintf('%s par=%s',punch_bin,fpunch));
  
  t=read_bin(ftime,nx);
  
  
