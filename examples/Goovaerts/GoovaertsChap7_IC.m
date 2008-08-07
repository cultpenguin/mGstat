[data,header]=read_eas('transect.dat');
[pdata,pheader]=read_eas('prediction.dat');

x_obs=data(:,1);
v_obs=data(:,4);
iatt=4;
piatt=5;
iuse=find(data(:,iatt)~=-99);
x_obs=data(iuse,1);
v_obs=data(iuse,4);
nd=length(x_obs);

x=data(:,1);


%%%
% CODE THE CONTINOUS DATA INTO INDICATORS
%

% FIND DATA VALUES CORRESPONDING TO SPECIFIC PROB QUANTILES
pk=[0.1:.1:.9];
%pk=[0.1:.05:.9];
%pk=[0.01:.01:.99];
v_range=icpdf(v_obs,pk);
%v_range=icpdf(pdata(:,piatt),pk);
[ind,lev]=indicator_transform_con(v_obs,v_range);

nr=length(v_range);

print -dpng IC0.png

figure;
subplot(2,1,1)
plot(x_obs,v_obs,'k*')
hold on
for i=1:nr
  plot([min(x) max(x)],[v_range(i) v_range(i)],'b-')
  text(max(x),v_range(i),['pk=',num2str(pk(i))])
end
xpred=[1.625 3.375 2.5 6];
for i=1:4
  plot([xpred(i) xpred(i)],[0 4],'r-')
  text(xpred(i)+.02,[3.5],sprintf('u_%d',i))
end
hold off

subplot(2,1,2)
plot(x_obs,v_obs,'k*')
hold on
for i=1:nr
  for j=1:nd
    if ind(j,i)==0,
      col=[1 0 0];
    else
      col=[0 0 0];
    end
    plot(x_obs(j),v_range(i),'.','MarkerSize',ind(j,i)*20+10,'Color',col)
  end
end
hold off  


print -dpng IC1.png


figure

plot(v_range,ind(1,:),'-*')
ax=axis;
axis([ax(1) ax(2) -0.1 1.1])
xlabel('VALUE'),xlabel('CPDF')
title('A PRIORI CPDF at DATA LOCATION 1')
print -dpng IC2.png


%%%
% THE MEAN 'A PRIORI' CPDF
mean_cpdf=mean(ind);
figure
plot(v_range,mean_cpdf,'k-*')
ax=axis;
axis([ax(1) ax(2) 0 1])
xlabel('VALUE'),xlabel('CPDF')
title('A PRIORI CPDF AWAY FROM  DATA LOCATIONS')

print -dpng IC3.png


%%
% SIMPLE KRIGING OF EACH DATA THRESHOLD
% ESTIMATE POSTOERIOR CPDF AT X-LOCATIONS xpred
%
V='0.3 Nug(0) + 0.30 Sph(0.2) + 0.26 Sph(1.3)';
xpred=[1.625 3.375 2.5 6];
nx=length(xpred);
for ix=1:nx
  for ir=1:nr
    [v_est(ir,ix),v_var(ir,ix)]=krig_sk(x_obs,ind(:,ir),xpred(ix),V,mean_cpdf(ir));
    [v_est_ok(ir,ix),v_var_ok(ir,ix)]=krig_ok(x_obs,ind(:,ir),xpred(ix),V);
  end
  L{ix}=['u',num2str(ix)];
end

figure
plot(v_range,v_est,'-*')
legend(L,4)
xlabel('VALUE')
ylabel('POSTERIOR CPDF')
title('RESULTS OF SIMPLE INDICATOR KRIGING')

hold on
plot(v_range,v_est_ok,'-*','linewidth',2)
legend(L,4)
xlabel('VALUE')
ylabel('POSTERIOR CPDF')
title('RESULTS OF ORDINAIRY INDICATOR KRIGING')
hold off

print -dpng IC4.png


val_thres=0.8;
for ix=1:nx
  %[v_est(ir,ix),v_var(ir,ix)]=krig_sk(x_obs,ind(:,ir),xpred(ix),V,mean_cpdf(ir));
  %[v_est_ok(ir,ix),v_var_ok(ir,ix)]=krig_ok(x_obs,ind(:,ir),xpred(ix),V);
  rnoise=rand(size(v_est(:,ix))).*.00001;
  sk(ix)=interp1(v_range(:)',v_est(:,ix),val_thres);
  ok(ix)=interp1(v_range(:)',v_est_ok(:,ix),val_thres);
 
    
end
disp(sprintf('SK Prob of exceeding %3.1g',val_thres))
disp(sk)
disp(sprintf('OK Prob of exceeding %3.1g',val_thres))
disp(ok)



%%%% 
% KRIG ALONG PROFILE 
xpred=x';
nx=length(xpred);
for ir=1:nr
  for ix=1:nx
    [v_est_sk(ir,ix),v_var_sk(ir,ix)]=krig_sk(x_obs,ind(:,ir),xpred(ix),V,mean_cpdf(ir));
    [v_est_ok(ir,ix),v_var_ok(ir,ix)]=krig_ok(x_obs,ind(:,ir),xpred(ix),V);
  end
  L{ir}=sprintf('Prob Z<%4.2g',v_range(ir));
end

figure;
subplot(2,1,1)
plot(xpred,1-v_est_sk,'-')
legend(L)
subplot(2,1,2)
plot(xpred,1-v_est_ok,'-')
legend(L)
print -dpng IC5.png

figure
for i=1:nx;
  subplot(2,1,1)
  plot(x_obs,v_obs,'k*')
  hold on
  plot([xpred(i) xpred(i)],[0 4],'r-')
  hold off
  ylabel('value')
  xlabel('Distance')
  axis([min(xpred) max(xpred) 0 4])
  
  subplot(2,3,5)
  plot(v_range,v_est_sk(:,i),'r-*')
  axis([0 4 -.01 1.01])
  xlabel('value')
  ylabel('Prob(Z<z|u)')
  drawnow
  pause(.5)
end
  
suptitle('Results of Indicator Kriging')