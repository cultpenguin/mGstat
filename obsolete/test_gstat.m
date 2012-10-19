% test_gstat : An mfile to test the Matlab interface to GSTAT
[p,Pheader]=read_eas('prediction.dat');
% CREATE PRED GRID
dx=.04;
x=[0:dx:5.5];
y=[0:dx:6];
nx=length(x);
ny=length(y);
write_arcinfo_ascii('2dmask',zeros(ny,nx),x,y,[],0,0);


% G=read_gstat_par('gstat_ok.cmd');
[pred,var,pcv,mask,G]=mgstat('gstat_ok.cmd');
ivar=G.data{1}.v;


subplot(2,2,1)
imagesc(x,y,pred{1})
hold on
MS=30
plot(p(:,1),p(:,2),'k.','MarkerSize',MS*1.2)
scatter(p(:,1),p(:,2),MS,p(:,ivar),'filled')
hold off
set(gca,'ydir','normal')
colorbar
axis image

subplot(2,2,2)
imagesc(x,y,var{1})
set(gca,'ydir','normal')
axis image
colorbar


subplot(2,1,2)
pred{1}(find(var{1}>.95))=NaN;
imagesc(x,y,pred{1})
hold on
MS=30
plot(p(:,1),p(:,2),'k.','MarkerSize',MS*1.2)
scatter(p(:,1),p(:,2),MS,p(:,ivar),'filled')
hold off
set(gca,'ydir','normal')
colorbar
axis image

