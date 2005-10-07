% GoovaertsChap5_sk : Goovaerts Example : Chapter 5 Simple Kriging

[data,header]=read_eas('transect.dat');
[pdata,pheader]=read_eas('prediction.dat');

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
figure;

%options.mean=0;
options.max=3;

Cd_mean=mean(Cd_obs);
for i=1:length(x);
  [d_sk(i),d_sk_var(i),lambda_sk,Ksk]=krig(x_obs,Cd_obs,x(i),Vobj);
  [d_ok(i),d_ok_var(i),lambda_ok,Kok]=krig(x_obs,Cd_obs,x(i),Vobj,options);
  % [d_sk2(i),d_sk_var2(i),lambda_sk2,Ksk2]=krig_sk(x_obs,Cd_obs,x(i),Vobj,Cd_mean);
  weight_mean_sk(i)=1-sum(lambda_sk);
  if (i/10)==round(i/10), 
    disp(sprintf('%d/%d',i,length(x))), 
    subplot(2,1,1)
    plot(x,d_sk,'b-','linewidth',2);
    hold on  
    plot(x_obs,Cd_obs,'k.','MarkerSize',20);
    hold off
    subplot(2,1,2)
    plot(x,weight_mean_sk,'b-','linewidth',2);
    drawnow
  end
end
subplot(2,1,1);ax=axis;axis([min(x) max(x) ax(3) ax(4)])
legend('Simple kriging')
subplot(2,1,2);ax=axis;axis([min(x) max(x) ax(3) ax(4)])
legend('Weight of SK mean')
suptitle(V)
print -dpng GoovChap5_5.2.png


figure
plot(x,d_sk,'b-','linewidth',2);
hold on  
plot(x,d_sk-2*d_sk_var,'b-','linewidth',.2);
plot(x,d_sk+2*d_sk_var,'b-','linewidth',.2);
plot(x_obs,Cd_obs,'k.','MarkerSize',20);
plot(x,x.*0,'k-','linewidth',2);
hold off
ax=axis;axis([min(x) max(x) ax(3) ax(4)])
title('Simple Kriging estimates and 95%% confidence interval')
print -dpng Goovaerts7_ConfInt.png


% PLOT HISTOGRAM AND ASSUMED GAUSSIAN 
x1=linspace(-2,7,40);
x2=linspace(-2,7,40);
gvar=sum([Vobj.par1]);
figure
subplot(2,1,1)
h1=hist(Cd_obs,x1);
bar(x1,h1./sum(h1));
hold on
y = normpdf(x2,mean(Cd_obs),gvar);
plot(x2,y./sum(y),'-')
hold off
title('using transect Cd data only')
xlabel('Cd');ylabel('Probability')

d2=pdata(:,5);
subplot(2,1,2)
h2=hist(d2,x1);
bar(x1,h2./sum(h2));
hold on
y = normpdf(x2,mean(d2),gvar);
plot(x2,y./sum(y),'-')
hold off
title('using ALL Cd data')
xlabel('Cd');ylabel('Probability')
suptitle('Comparison of true vs. assumed PDF')
print -dpng Goovaerts7_CompareCdToNormalPDF.png

figure

subplot(2,1,1)
plot(sort(Cd_obs),(1:10)./10,'*k-');
cpdf = normcdf(x2,mean(Cd_obs),gvar);
hold on
plot(x2,cpdf,'r-')
hold off
title('using transect Cd data only')
xlabel('Cd');ylabel('Probability')
subplot(2,1,2)
plot(sort(d2),(1:length(d2))./length(d2),'*k-');
hold on
y = normcdf(x2,mean(d2),gvar);
plot(x2,y,'r-')
hold off
title('using ALL Cd data')
xlabel('Cd');ylabel('Probability')
suptitle('Comparison of true vs. assumed CDF')
print -dpng Goovaerts7_CompareCdToNormalCDF.png
