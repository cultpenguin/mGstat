% GoovaertsChap5_kt : Goovaerts Example : Chapter 5 Kriging With A Trend
[data,header]=read_eas('transect.dat');

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

figure;
for i=1:length(x);
  [d_sk(i),d_sk_var(i),lambda_sk]=krig_sk(x_obs,Cd_obs,x(i),Vobj);
  weight_mean_sk(i)=1-sum(lambda_sk);
  [d_ok(i),d_ok_var(i),lambda_ok,dmean_ok(i)]=krig_ok(x_obs,Cd_obs,x(i),Vobj);
  [d_tr(i),d_tr_var(i)]=krig_trend(x_obs,Cd_obs,x(i),Vobj);
  [d_trtr(i)]=krig_trend_trend(x_obs,Cd_obs,x(i),Vobj);
  if (i/10)==round(i/10), 
    disp(sprintf('%d/%d',i,length(x))), 

    subplot(2,1,1)
    plot(x,d_sk,'-b','linewidth',2);
    hold on  
    plot(x,d_ok,'r-','linewidth',2);
    plot(x,d_tr,'g-','linewidth',2);
    plot(x_obs,Cd_obs,'k.','MarkerSize',20);
    hold off
    legend('SK','OK','KT')

    subplot(2,1,2)
    plot(x,dmean_ok,'r-',x,d_trtr,'g-','linewidth',2);
    legend('OK Trend','KT trend')
    drawnow
  end
end
subplot(2,1,1);
ax=axis;axis([min(x) max(x) ax(3) ax(4)])
subplot(2,1,2);
ax=axis;axis([min(x) max(x) ax(3) ax(4)])

suptitle(V)
print -dpng GoovChap5_5.6.png
