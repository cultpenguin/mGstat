% GoovaertsChap5_ok : Goovaerts Example : Chapter 5 Ordinary Kriging

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


% FIG 5.2
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
f1=figure;
f2=figure;
Cd_mean=mean(Cd_obs);
for i=1:length(x);
  figure(f1);
  [d_sk(i),d_sk_var(i),lambda_sk]=krig_sk(x_obs,Cd_obs,x(i),Vobj,Cd_mean);
  weight_mean_sk(i)=1-sum(lambda_sk);
  [d_ok(i),d_ok_var(i),lambda_ok,dmean_ok(i)]=krig_ok(x_obs,Cd_obs,x(i),Vobj);
  
  if (i/10)==round(i/10), 
    figure(f2)
    disp(sprintf('%d/%d',i,length(x))), 
    subplot(2,1,1)
    plot(x,d_sk,'-b','linewidth',2);
    hold on  
    plot(x,d_ok,'r-','linewidth',2);
    plot(x_obs,Cd_obs,'k.','MarkerSize',20);
    hold off
    subplot(2,1,2)
    plot(x,dmean_ok,'r-','linewidth',2);
    drawnow
  end
end
figure(f2)
subplot(2,1,1);ax=axis;axis([min(x) max(x) ax(3) ax(4)])
legend('Simple kriging','Ordinary kriging')
subplot(2,1,2);ax=axis;axis([min(x) max(x) ax(3) ax(4)])
legend('OK Trend')
suptitle(V)
print -dpng GoovChap5_5.3.png
