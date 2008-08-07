% GoovaertsChap5_compare : Compare OK/SK kriging

[data,header]=read_eas('transect.dat');
[pdata,pheader]=read_eas('prediction.dat');

x=data(:,1);
Cd=data(:,4);

% find data
id=find(Cd~=-99);
x_obs=x(id);
Cd_obs=Cd(id);
nobs=length(x_obs);

Cd_obs_err=ones(size(Cd_obs,1),1).*.8;

%x=[min(x):.01:max(x)];
x=linspace(min(data(:,1)),max(data(:,1)),1001);
%x=[0:.05./5:7];
nx=length(x);


% FIG 5.2
V='0.3 Nug(0) + 0.30 Sph(0.2) + 0.26 Sph(1.3)';
Vobj=deformat_variogram(V);

clf;
clear d_*

options_ok.max=3;
options_sk.mean=mean(Cd_obs);
options_tr.max=43;
options_tr.trend=1;

Cd_mean=mean(Cd_obs);
for i=1:length(x);
  [d_sk(i),d_sk_var(i),lambda_sk,Ksk]=krig(x_obs,Cd_obs,x(i),Vobj,options_sk);
  [d_sk2(i),d_sk2_var(i),lambda_sk2,Ksk2]=krig(x_obs,[Cd_obs Cd_obs_err],x(i),Vobj,options_sk);
  [d_ok(i),d_ok_var(i),lambda_ok,Kok]=krig(x_obs,Cd_obs,x(i),Vobj,options_ok);
  [d_tr(i),d_tr_var(i),lambda_tr,Ktr,ktr]=krig(x_obs,Cd_obs,x(i),Vobj,options_tr);
%  [d_tr(i),d_tr_var(i),lambda_tr2,Ktr2,ktr2]=krig_trend(x_obs,Cd_obs,x(i),Vobj);

  weight_mean_sk(i)=1-sum(lambda_sk);
  if (i/10)==round(i/10), 
    disp(sprintf('%d/%d',i,length(x))), 

    subplot(2,1,1)
    plot(x(1:i),[d_sk;d_sk2;d_ok;d_tr],'-','linewidth',2);
    hold on ;plot(x_obs,Cd_obs,'k.','MarkerSize',22);hold off

    subplot(2,1,2)
    plot(x(1:i),[d_sk_var;d_sk2_var;d_ok_var;d_tr_var],'-','linewidth',2);
    hold on ;plot(x_obs,Cd_obs.*0,'k.','MarkerSize',22);hold off
    
    
    drawnow
  end
end
subplot(2,1,1);ax=axis;axis([min(x) max(x) ax(3) ax(4)])
legend('SK','SK noisy','OK','TR')
xlabel('X')
ylabel('Kriging Mean')
title(V)

subplot(2,1,2);
ax=axis;axis([min(x) max(x) ax(3) ax(4)])
legend('Weight of SK mean')
ylabel('Kriging Variance')
print -dpng GoovChap5_compareKriging.m


