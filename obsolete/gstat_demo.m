

if exist('ex05.cmd')==2
  doTest1=1;
else
  doTest1=0;
end
if doTest1
  G=read_gstat_par('ex05.cmd');
  G.mgstat.parfile='demo.cmd';
  figure
  i=0;
  for par1=[0 .1 1 10];
    i=i+1;
    G.variogram{1}.V(1).par1=par1;
    subplot(2,2,i);
    gstat_plot(G,20);
    title(sprintf('par1=%7.4g',par1))
    axis image
  end
  suptitle('NUGGET TEST')
  set(findobj('type','axes'),'FontSize',7)
end

doTest2=0;
if doTest2
  G=read_gstat_par('ex05.cmd');
  G.mgstat.parfile='demo.cmd';
  figure
  i=0;
  G.variogram{1}.V(1).par1=0; % NO NUGGET 
  for par1=[1];
    for par2=[.1 100 200 400 1000 10000];
      i=i+1;
      G.variogram{1}.V(2).par1=par1;
      G.variogram{1}.V(2).par2=par2;
      subplot(2,3,i);
      gstat_plot(G,5);
      title(sprintf('%7.4g Sph(%7.4g)',par1,par2))
      axis off
      axis image;drawnow
    end
  end
  set(gcf,'Name','Sperical')
  %set(findobj('type','axes'),'FontSize',7)
end


doTest3=1;
if doTest3;
  rseed=1;
  dx=1;dy=dx;
  ax=110;ay=400;
  nx=250;ny=500;
  ix=nx*dx;
  iy=ny*dy;
  pop=1;
  med=1;
  nu=.7;
  data=vonk2d(rseed,dx,dy,ax,ay,ix,iy,pop,med,nu);

  figure
  subplot(2,2,1);imagesc(data);axis image
  title('Orig Map')
  
  ntestdata=20;
  x=round(rand(ntestdata,1)*(ix-1)+1);
  y=round(rand(ntestdata,1)*(iy-1)+1);

  %x=round(testdata(:,1)*(ix-1)+1);
  %y=round(testdata(:,2)*(iy-1)+1);
  
  obs=ones(ntestdata,1);
  for i=1:ntestdata, obs(i)=data(y(i),x(i));end
  header{1}='Xlocation, cells';
  header{2}='Ylocation, cells';
  header{3}='Observation, []';
  eas_file='demo3.eas';
  write_eas(eas_file,[x y obs],header);
  
  hold on;
  plot(x,y,'k.')
  hold off;
  
  % data
  G.data{1}.data='obs';
  G.data{1}.file=eas_file;
  G.data{1}.x=1;
  G.data{1}.y=2;
  G.data{1}.v=3;
  %G.data{1}.min=floor(min(obs));
  %G.data{1}.max=ceil(max(obs));
  %G.data{1}.radius=30;
  %G.data{1}.sk_mean=mean(obs);
  % variogram
  G.variogram{1}.data=G.data{1}.data;
  clear V;
  V(1).par1=-2.5;V(1).par2=0;  V(1).type='Nug';
  V(2).par1=59;V(2).par2=157;V(2).type='Sph';
  G.variogram{1}.V=V;
  
  % mask
  xx=[1:1:nx];
  yy=[1:1:ny];
  mask=data.*0+1;
  mask_file='maskdemo.ascii';
  % write_gstat_ascii(mask_file,mask,xx,yy,-9999);
  write_arcinfo_ascii(mask_file,mask,xx,yy,-9999);

  G.mask{1}.file=mask_file;
  
  
  %predictions
  pred_file='demo3_pred';
  G.predictions{1}.data=G.data{1}.data;
  G.predictions{1}.file=pred_file;
  
  Gfile='demo3.cmd';
  write_gstat_par(G,Gfile);
  
  subplot(2,2,2);
  gstat_plot(G,20)
  axis image;
  
  
end
  
