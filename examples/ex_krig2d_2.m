true_data=membrane(1); % Matlab splash image

x_arr=1:1:size(true_data,2);
y_arr=1:1:size(true_data,1);

nd=30;
x=round(rand(1,nd)*(length(x_arr)-1)+1);
y=round(rand(1,nd)*(length(y_arr)-1)+1);
val=zeros(1,nd);
for i=1:nd,  val(i)=true_data(y(i),x(i));  end

V=['0.1 Nug(0) + 1 Sph(53)'];
[pred,pred_var,x_arr,y_arr,G]=mgstat_krig2d(x,y,val,V,x_arr,y_arr);
clf;

subplot(2,2,1)
imagesc(x_arr,y_arr,true_data);axis image
cax=caxis;title('True');colorbar

subplot(2,2,2)
imagesc(x_arr,y_arr,pred);axis image
caxis(cax);title('Predicted')
hold on;cplot(x,y,val,[],20);hold off
colorbar

subplot(2,2,3);title('Difference')
imagesc(x_arr,y_arr,true_data-pred);axis image
caxis([-.2 .2]);
colorbar
title('Difference')

subplot(2,2,4);
imagesc(x_arr,y_arr,pred_var);axis image
title('Variance')
colorbar

suptitle(V)
