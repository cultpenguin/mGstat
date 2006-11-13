function [t,time]=fast_fd_2d_traveltime(x,y,v,S,R);

ns=size(S,1);
nr=size(R,1);
[xx,yy]=meshgrid(x,y);

t=ones(ns*nr,1);

for ishot=1:ns
  if ( (ns>10) & ( (ishot/5)==round(ishot/5) ) )
    progress_txt(ishot,ns,'Calling NFD ')
  end
  t0=fast_fd_2d(x,y,v,S(ishot,:));

  time{ishot}=interp2(xx,yy,t0,R(:,1),R(:,2));
  i0=(ishot-1)*nr;
  t( i0+1:i0+nr)=time{ishot};


end
