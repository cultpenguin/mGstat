% GoovaertsChap5_kt : Goovaerts Example : Chapter 5 Kriging With A Trend
dwd=[mgstat_dir,filesep,'examples',filesep,'data',filesep,'jura',filesep];
[pdata,pheader]=read_eas([dwd,'prediction.dat']);
[data,header]=read_eas([dwd,'transect.dat']);

x=data(:,1);
Cd=data(:,4);

% find data
id=find(Cd~=-99);
x_obs=x(id);
Cd_obs=Cd(id);
nobs=length(x_obs);

%x=[min(x):.01:max(x)];
%x=linspace(min(data(:,1)),max(data(:,1)),1001);
%x=[0:.05./5:7];
nx=length(x);


% FIG 5.6
V='0.3 Nug(0) + 0.30 Sph(0.2) + 0.26 Sph(1.3)';
Vobj=deformat_variogram(V);
d_sk=zeros(1,nx).*NaN;
d_sk_var=zeros(1,nx).*NaN;
weight_mean_sk=zeros(1,nx).*NaN;
lambda_sk=zeros(nobs,nx).*NaN;
d_ok=d_sk;
d_ok_var=d_sk_var;
dmean_ok=d_sk;
lambda_ok=lambda_sk;
d_tr=d_sk;
d_tr_var=d_sk_var;
d_trtr=d_tr;


options_sk.mean=mean(Cd_obs);
[d_sk,d_sk_var,lambda_sk,Ksk]=krig(x_obs,Cd_obs,x,Vobj,options_sk);
weight_mean_sk=1-sum(lambda_sk);
options_ok.max=3;
[d_ok,d_ok_var,lambda_ok,Kok]=krig(x_obs,Cd_obs,x,Vobj,options_ok);
options_kt.polytrend=1;
%options_kt.max=3;
[d_kt,d_kt_var,lambda_kt,Kkt]=krig(x_obs,Cd_obs,x,Vobj,options_kt);

options_kt2=options_kt;
options_kt2.trend=1;
%options_kt2.max=3;
[d_kt2,d_kt2_var,lambda_kt2,Kkt2]=krig(x_obs,Cd_obs,x,Vobj,options_kt2);

figure;
subplot(2,1,1)
plot(x,d_sk,'-b','linewidth',2);
hold on
plot(x,d_ok,'r-','linewidth',2);
plot(x,d_kt,'g-','linewidth',2);
plot(x,d_kt2,'k-','linewidth',1);
plot(x_obs,Cd_obs,'k.','MarkerSize',20);
hold off
legend('SK','OK','KT','TREND')

subplot(2,1,2)
plot(x,dmean_ok,'r-',x,d_trtr,'g-','linewidth',2);
legend('OK Trend','KT trend')
drawnow

keyboard
subplot(2,1,1);
ax=axis;axis([min(x) max(x) ax(3) ax(4)])
subplot(2,1,2);
ax=axis;axis([min(x) max(x) ax(3) ax(4)])

suptitle(V)
print -dpng GoovChap5_5.6.png
