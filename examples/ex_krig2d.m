% ex_krig2d : Examples of simple 2D kriging
%
%

% SELECT THE DEMOS TO RUN
doplot=[1 2];

if find(doplot==1)
  x=  [2 2 4 4 3];
  y=  [2 4 2 4 3];
  val=[1 3 2 4 0];
  x_arr=[1:.01:5];
  y_arr=[1:.01:5];
  V=['0.0 Nug(0) + 1 Sph(10.057)'];
  figure  
  [pred,pred_var,x_arr,y_arr,G]=mgstat_krig2d(x,y,val,V,x_arr,y_arr);
end

if find(doplot==2)

  true_data=membrane(1); % Matlab splash image

  x_arr=1:1:size(true_data,2);
  y_arr=1:1:size(true_data,1);
  
  nd=30;
  x=round(rand(1,nd)*(length(x_arr)-1)+1);
  y=round(rand(1,nd)*(length(y_arr)-1)+1);
  val=zeros(1,nd);
  for i=1:nd,  val(i)=true_data(y(i),x(i));  end

  V=['0.1 Nug(0) + 1 Sph(53)'];
  figure  
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
 
  %subplot(2,2,4)
  %arr=[0:.2:10];contour(true_data,arr,'k');hold on;contour(pred,arr,'r');hold off;


  
end

