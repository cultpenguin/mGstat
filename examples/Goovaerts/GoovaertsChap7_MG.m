% GoovaertsChap7_MG : MultiGaussian Approach

% read data
dwd=[mgstat_dir,filesep,'examples',filesep,'data',filesep,'jura',filesep];
[data,header]=read_eas([dwd,'transect.dat']);
x=data(:,1); % x data column

id=find(data(:,4)~=-99);

x_obs=data(id,1); % x data column
v_obs=data(id,4); % Cd data column
n_obs=length(id);
v_mean=mean(v_obs);

% RANK TRANSFORM
r_obs=rank_transform(v_obs);

% NORMAL SCORE TRANSFORMATION OF THE DATA
%[v_obs_nscore,normscore,d_obs,pk]=nscore(v_obs);
[v_obs_nscore,o_nscore]=nscore(v_obs);
w1=1;w2=1;dmin=0;dmax=5;
[v_obs_nscore1,o_nscore1]=nscore(v_obs,w1,w2,dmin,dmax);
v_mean_nscore=mean(v_obs_nscore);


% THE VARIOGRAM MODEL
V='0.3 Nug(0) + 0.30 Sph(0.2) + 0.26 Sph(1.3)';
Vnscore='0.3488 Nug(0) + 0.3488 Sph(0.2) + 0.3023 Sph(1.3)';


%% SK KRIGING OF NORMAL SCORES NAD ORIGINAL DATA
xu=[1.625 3.375 2.5 6];
options.mean=v_mean_nscore;
keyboard
[v_est_nscore,v_var_nscore]=krig(x_obs,v_obs_nscore,xu,Vnscore,options);
optons.mean=v_mean;
[v_est,v_var]=krig(x_obs,v_obs,xu,V,options);

%% SK KRIGING OF WHOLE X_ARRAY
options.mean=v_mean_nscore;
[v2_est_nscore,v2_var_nscore]=krig(x_obs,v_obs_nscore,x,Vnscore,options);
options.mean=v_mean;
[v2_est,v2_var]=krig(x_obs,v_obs,x,V,options);

%v2_est_inscore=inscore(v2_est_nscore,normscore,v_obs);
v_est_inscore=inscore(v_est_nscore,o_nscore);
v2_est_inscore=inscore(v2_est_nscore,o_nscore1);
v2_var_inscore_m=inscore(v2_est_nscore-2.*v2_var_nscore,o_nscore1);
v2_var_inscore_p=inscore(v2_est_nscore+2.*v2_var_nscore,o_nscore1);

figure(1)
%% Figure 7.7
subplot(2,1,1);
plot(x_obs,v_obs,'k*',[min(x) max(x)],[1 1].*v_mean,'b-')
ax=axis;axis([min(x) max(x) -1 5])
ylabel('Data Value')
hold on
plot(xu,v_est,'go')
plot(x,v2_est,'g-','linewidth',2)
%plot(x,v2_est-2.*v2_var,'r-')
%plot(x,v2_est+2.*v2_var,'r-')
plot(xu,v_est_inscore,'ro')
plot(x,v2_est_inscore,'r-','linewidth',2)
%plot(x,v2_var_inscore_m,'g-')
%plot(x,v2_var_inscore_p,'g-')
hold off
for i=1:4
  text(xu(i)+.08,v_est(i)+.3,num2str(i))
end
legend('OBS','MEAN','SK EST','SK','SK MG EST','SK MG')

subplot(2,1,2);
plot(x_obs,v_obs_nscore,'k*',[min(x) max(x)],[1 1].*0,'r-')
ax=axis;axis([min(x) max(x) ax(3) ax(4)])
ylabel('Normal Score Data Value')
hold on
plot(xu,v_est_nscore,'ro')
plot(x,v2_est_nscore,'r-')
hold off
for i=1:4
  text(xu(i)+.07,v_est_nscore(i)+.3,num2str(i))
end
%print -dpng GoovaertsChap7_A


figure(2)
x_norm=[-3:.1:3];
for i=1:4
  subplot(2,2,i);
  p(i,:) = normcdf(x_norm,v_est_nscore(i),v_var_nscore(i));
  plot(x_norm,p(i,:))

%  x_norm_inscore=inscore(x_norm,normscore,v_obs);
%  plot(x_norm_inscore,p(i,:))
  
  title(num2str(i))
  xlabel('X')
  ylabel('CPDF')
  grid on
end
suptitle('Normal Score CPDF')
print -dpng GoovaertsChap7_B

figure(3)
x_norm=[-3:.1:3];
for i=1:4
  subplot(2,2,i);

  x_norm_inscore=inscore(x_norm,o_nscore1);
  %x_norm_inscore=inscore(x_norm,normscore,v_obs);
  plot(x_norm_inscore,p(i,:))
  
  title(num2str(i))
  xlabel('X')
  ylabel('CPDF')
  grid on
end
suptitle('Posterior Probability')
print -dpng GoovaertsChap7_C




figure(4);
[v_obs_nscore,o_nscore]=nscore(v_obs);
w1=2;w2=.5;dmin=-4;dmax=6;
[v_obs_nscore1,o_nscore1]=nscore(v_obs,w1,w2,dmin,dmax);
w1=1;w2=1;dmin=0;dmax=5;
[v_obs_nscore2,o_nscore2]=nscore(v_obs,w1,w2,dmin,dmax);


plot(sort(o_nscore.d),o_nscore.pk,'k')
hold on
plot(sort(o_nscore1.d),o_nscore1.pk,'bd')
plot(sort(o_nscore2.d),o_nscore2.pk,'r*')
hold off
legend('No tails','w1=2,w2=0.5,dmin=-4dmax=6','w1=1,w2=1,dmin=0,dmax=5',2)
print -dpng GoovaertsChap7_E



figure(5)
x=[1 2 3 4 5];
d=[25,13,8,9,1];
[d_obs_nscore,o_nscore]=nscore(d);

plot(sort(d),o_nscore.pk,'-*')
xlabel('z, data values')
ylabel('Prob(Z<=z)')
axis([0 26 0 1])
print -dpng GoovaertsChap7_testA

figure(6)

subplot(1,2,1)
plot(sort(d),o_nscore.pk,'-*')
xlabel('z, data values')
ylabel('Prob(Z<=z)')
title('orig data')
axis([0 26 0 1])
subplot(1,2,2)
cpdf_norm=normcdf(x_norm,0,1);
plot(sort(d_obs_nscore),o_nscore.pk,'r*',x_norm,cpdf_norm,'k-');
legend('Normal Score Data','Gaussian CPDF, mean00, var=1',2)
xlabel('z, data values')
ylabel('Prob(Z<=z)')
title('normal score')
axis([-3 3 0 1])
print -dpng GoovaertsChap7_testA


figure(7)
x=linspace(0,30,100);
cpdf_norm=normcdf(x,mean(d),sqrt(var(d)));
plot(sort(d),o_nscore.pk,'-*',x,cpdf_norm,'k-')
legend('data','Best fitting Gaussian Model')
print -dpng GoovaertsChap7_Compare

return

