% Goovaerts Example : Chapter 5
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
figure;
for i=1:length(x);
  [d_sk(i),d_sk_var(i),lambda_sk(:,i),Ksk]=krig_sk(x_obs,Cd_obs,x(i),Vobj);
  if (i/10)==round(i/10), 
    disp(sprintf('%d/%d',i,length(x))), 
    weight_mean_sk=1-sum(lambda_sk);
    subplot(2,1,1)
    plot(x,d_sk,'-','linewidth',2);
    hold on  
    plot(x_obs,Cd_obs,'k.','MarkerSize',20);
    hold off
    subplot(2,1,2)
    plot(x,weight_mean_sk,'g-','linewidth',2);
    drawnow
  end
end
subplot(2,1,1);ax=axis;axis([min(x) max(x) ax(3) ax(4)])
legend('Simple kriging')
subplot(2,1,2);ax=axis;axis([min(x) max(x) ax(3) ax(4)])
legend('Weight of SK mean')
suptitle(V)
print -dpng GoovChap5_5.2.png
return


%V='0.3 Nug(0) + 0.30 Sph(0.2) + 0.26 Sph(1.3)';
V='0.30 Sph(0.2) + 0.26 Sph(1.3)';
%V='0.3 Nug(0) + 0.30 Gau(0.2) + 0.26 Gau(1.3)';
%V='0 Nug(0) + 1 Sph(2)';
%V='0.2 Nug(0) + .8 Sph(2)';
%V='0.5 Nug(0) + .5 Sph(2)';
%V='0.8 Nug(0) + .2 Sph(2)';
%V='0 Nug(0) + 1 Sph(2)';
if isstr(V),
	V=deformat_variogram(V);
end 

nx=length(x);
d_sk=zeros(1,nx);
d_ok=zeros(1,nx);
d_tr=zeros(1,nx);
d_trtr=zeros(1,nx);
d_sk_var=zeros(1,nx);
d_ok_var=zeros(1,nx);
d_tr_var=zeros(1,nx);
%lambda_sk=zeros(1,nx)';
%lambda_ok=zeros(1,nx)';
%lambda_kt=zeros(1,nx)';

for i=1:length(x);
  if (i/10)==round(i/10), disp(sprintf('%d/%d',i,length(x))), end
  [d_sk(i),d_sk_var(i),lambda_sk(:,i)]=krig_sk(x_obs,Cd_obs,x(i),V);
  [d_ok(i),d_ok_var(i),lambda_ok(:,i),dmean_ok(i)]=krig_ok(x_obs,Cd_obs,x(i),V);
  [d_tr(i),d_ok_var(i),lambda_tr(:,i)]=krig_trend(x_obs,Cd_obs,x(i),V);
  [d_trtr(i)]=krig_trend_trend(x_obs,Cd_obs,x(i),V);
end

figure(gcf);
subplot(2,1,1)
plot(x,d_sk,'g-',x,d_ok,'k-',x,d_tr,'b-',x_obs,Cd_obs,'ko','linewidth',2)
hold on
%plot(x,[d_sk-d_sk_var;d_sk+d_sk_var],'g-')
%plot(x,[d_ok-d_ok_var;d_ok+d_ok_var],'k-')
hold off
legend('SK','OK','KT','data')

subplot(2,1,2)
plot(x,dmean_ok,'k-')
hold on
plot(x,d_trtr,'b-')
plot(x,1-sum(lambda_sk));
hold off
legend('OK trend','KT trend','Weight of SK mean')

%plot(x,d_ok,'k-',x_obs,Cd_obs,'ko')
%legend('OK','data')