x0=1.2;
x=  [2 2 4 4 13]+1.2;
y=  [2 4 2 4 8];
val=[1 3 2 4 0];
x_arr=[-15:.1:15];
y_arr=[1:.1:10];
V=['0.0 Nug(0) + 1 Sph(10.057)'];
[pred,pred_var,x_arr,y_arr,G]=mgstat_krig2d(x,y,val,V,x_arr,y_arr);
