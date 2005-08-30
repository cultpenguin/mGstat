%
%
%
fpred=['/home/tmh/TEACHING/GEOSTAT_COURSE/DATA/Goovaerts/prediction.dat'];
[pred,hpred]=read_eas(fpred);
ftran=['/home/tmh/TEACHING/GEOSTAT_COURSE/DATA/Goovaerts/transect.dat'];
[tran,htran]=read_eas(ftran);

pos_known=[pred(:,1),pred(:,2)];
val_known=log(pred(:,6));
  val_known=repmat(val_known(:,1),1,2);
  val_known(:,2)=0.1; % NO UNCERTAINTY
nx=40;ny=nx;
x=linspace(0,5,nx);
y=linspace(0,6,ny);
[xx,yy]=meshgrid(x,y);
pos_est=[xx(:) yy(:)];
n_est=size(pos_est,1);

V=deformat_variogram('.1 Gau(.4)');
%gvar=sum([V.par1]);
gvar=1;

used=[1:1:size(pos_known,1)];
%used=[1:1:size(pos_known,1)];
used=[1 2];

options.noprecalc_d2d=1;
options.precalc_d2u=1;
options.max=15;
options.target_hist=val_known(:,1);
options.target_hist=1+randn(1200,1)*1;


c=2.5;v=1;
options.target_hist=[-c+randn(1200,1).*v; c+randn(1200,1).*v];


options.target_hist=randn(1000,1);

%%%% SIMULATION

options.max=10;
options.mean=0;
options.nsim=20;
[MulG,p]=create_nscore_lookup(options.target_hist);
options.MulG=MulG;
options.p=p;
profile on
%[simdata,options]=dssim(pos_known(used,:),val_known(used,:),pos_est,V,options);
[simdata,options]=dssim(pos_known(used,:),[0 0;0.1 0.1],pos_est,V,options);
profile report
