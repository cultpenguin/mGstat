rand('seed',1);randn('seed',1);
ndata=30;
pos_known=rand(ndata,2)*10;
val_known=randn(ndata,1); % 
val_var=zeros(ndata,1)+.1; % 
V='1 Sph(8,.4,30)';   % Select variogram model (this one is anisotropic)
x_est=[-2:.25:12]';nx=length(x_est);
y_est=[-2:.25:12]';ny=length(y_est);
[xx,yy]=meshgrid(x_est,y_est);
pos_est=[xx(:) yy(:)];
clear options;
options.null='';
[d_est_ok,d_var_ok]=krig(pos_known,[val_known val_var],pos_est,V,options);
options.mean=mean(val_known);
[d_est_sk,d_var_sk]=krig(pos_known,[val_known val_var],pos_est,V,options);
options.polytrend=2;
[d_est_kt,d_var_kt]=krig(pos_known,[val_known val_var],pos_est,V,options);

cax1=[-1 1];
cax2=[0 1];
set_paper('landscape');
subplot(2,3,1);imagesc(x_est,y_est,reshape(d_est_sk,ny,nx));caxis(cax1);axis image
title('SK mean')
subplot(2,3,4);imagesc(x_est,y_est,reshape(d_var_sk,ny,nx));caxis(cax2);axis image
title('SK var')
subplot(2,3,2);imagesc(x_est,y_est,reshape(d_est_ok,ny,nx));caxis(cax1);axis image
title('OK mean')
subplot(2,3,5);imagesc(x_est,y_est,reshape(d_var_ok,ny,nx));caxis(cax2);axis image
title('OK var')
subplot(2,3,3);imagesc(x_est,y_est,reshape(d_est_kt,ny,nx));caxis(cax1);axis image
title('KT mean')
subplot(2,3,6);imagesc(x_est,y_est,reshape(d_var_kt,ny,nx));caxis(cax2);axis image
title('KT var')
print -dpng krigex7