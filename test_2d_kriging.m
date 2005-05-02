% test_2d_kriging : Goovaerts Example Chapter 5 Simple Kriging

[data,header]=read_eas('prediction.dat');

x_obs=data(:,1);
y_obs=data(:,2);
pos_obs=[x_obs y_obs];
val_obs=data(:,6);
nobs=length(x_obs);

x=[min(x_obs):.1:max(x_obs)];
y=[min(y_obs):.1:max(y_obs)];
%y=3;
%x=3;
nx=length(x);
ny=length(y);


V='0.3 Nug(0) + 0.30 Sph(0.2) + 0.26 Sph(1.3)';
%V='0.30 Sph(0.2) + 0.26 Sph(1.3)';
Vobj=deformat_variogram(V);
%figure;
for ix=1:length(x);
    if (ix/5)==round(ix/5), 
      disp(sprintf('%d/%d',ix,length(x))), 
    end
  for iy=1:length(y);
    pos_est=[x(ix) y(iy)];
    %2[d,dvar]=krig_trend(pos_obs,val_obs,pos_est,Vobj);
    %[d,dvar]=krig_trend_trend(pos_obs,val_obs,pos_est,Vobj);
    
    [d,dvar]=krig_ok(pos_obs,val_obs,pos_est,Vobj);
    %[d,dvar]=krig_sk(pos_obs,val_obs,pos_est,Vobj);
    val_est(iy,ix)=d;
    var_est(iy,ix)=dvar;
    % valm_est(iy,ix)=dmean;
  end
end

imagesc(x,y,val_est)
hold on
plot(x_obs,y_obs,'k.','MarkerSize',22)
scatter(x_obs,y_obs,20,val_obs,'filled')
hold off
axis image
set(gca,'Ydir','normal')

% NEXT FEW LINES SET TRANSPARENCY ACCORDING TO VARIANCE
%Amap=(1-var_est./max(var_est(:)));
%Amap=Amap./max(Amap(:));
%alpha(Amap);
