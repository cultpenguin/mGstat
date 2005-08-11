%
%
%
fpred=['/home/tmh/TEACHING/GEOSTAT_COURSE/DATA/Goovaerts/prediction.dat'];
[pred,hpred]=read_eas(fpred);
ftran=['/home/tmh/TEACHING/GEOSTAT_COURSE/DATA/Goovaerts/transect.dat'];
[tran,htran]=read_eas(ftran);

pos_known=[pred(:,1),pred(:,2)];
val_known=log(pred(:,5));
  val_known=repmat(val_known(:,1),1,2);
  val_known(:,2)=0.1; % NO UNCERTAINTY
nx=10;ny=nx;
x=linspace(0,5,nx);
y=linspace(0,6,ny);
[xx,yy]=meshgrid(x,y);
pos_est=[xx(:) yy(:)];
n_est=size(pos_est,1);

V=deformat_variogram('1 Sph(.5)');
%gvar=sum([V.par1]);
gvar=1;

used=[10:10:size(pos_known,1)];
%used=[1:1:size(pos_known,1)];

clear options;
options.precalc_d2u=1;
options.max=5;
%options.mean=1.3;
tic;
profile on
[d_est,d_var,d2d,d2u]=krig_npoint(pos_known(used,:),val_known(used,:),pos_est,V,options);
profile viewer
options.d2d=d2d;
t1=toc

figure(1)
scatter(pos_known(:,1),pos_known(:,2),20,val_known(:,1),'filled')
hold on
scatter(pos_est(:,1),pos_est(:,2),20,d_est(:,1))
hold off


options=rmfield(options,'d2d');
options=rmfield(options,'precalc_d2u');
[simdata]=sgsim(pos_known,val_known,pos_est,V,options);


return

options=rmfield(options,'precalc_d2u');

tic;
[d_est,d_var,options.d2d]=krig_npoint(pos_known,val_known,pos_est,V,options);
t2=toc

options.d2u=d2u;
tic;
[d_est,d_var,options.d2d,options.d2u]=krig_npoint(pos_known,val_known,pos_est,V,options);
t3=toc


V=deformat_variogram('1 Sph(1)');
options.max=10;
tic;
for i=1:n_est
  [d_est(i),d_var(i)]=krig(pos_known,val_known,pos_est(i,:),V,options);
%  [d_est(i),d_var(i)]=krig(pos_known,val_known,pos_est(i.:),V,options);
end
toc

scatter(pos_known(:,1),pos_known(:,2),20,val_known(:,1));
hold on
scatter(pos_est(:,1),pos_est(:,2),20,d_est,'filled');
hold off
