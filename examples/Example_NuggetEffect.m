d=read_eas('transect.dat');
id=find(d(:,4)~=-99);


x=d(:,1); % Cd
dx=x(2)-x(1);

% x=[min(x):dx*4:max(x)];
x=[min(x):dx:5.2];
x=[min(x):0.025:5.2];

v1=x.*NaN;
v2=x.*NaN;
v3=x.*NaN;
va1=x.*NaN;
va2=x.*NaN;
va3=x.*NaN;
x_obs=d(id,1);
v_obs=d(id,4);;

V{1}=deformat_variogram('1 Gau(.2)');
V{2}=deformat_variogram('.3 Nug(0) + .7 Gau(.2)');
V{3}=deformat_variogram('.3 Nug(0) + 1 Gau(.2)');
V{4}=deformat_variogram('1 Gau(.2)');

options.sk_mean=mean(v_obs);
options.max=10;
clear d_est d_var
for i=1:length(V);
  if i==4,
    unc_obs=0.*v_obs+0.3;
  else
    unc_obs=0.*v_obs;
  end

  % [d_est(:,i),d_var(:,i)]=gstat_krig(x_obs,[v_obs unc_obs],x',V{i});
  [d_est(:,i),d_var(:,i)]=gstat(x_obs,[v_obs unc_obs],x',V{i},options);

  L{i}=format_variogram(V{i},1);
end

subplot(2,1,1)
plot(x,d_est,'-')
hold on
plot(x_obs,v_obs,'k.','MarkerSize',20)
hold off
legend(L,-1)

subplot(2,1,2)
plot(x,d_var,'-')
legend(L,-1)

return

for i=1:length(x)  
 % [d_est,d_var,lambda_ok,d_mean]=krig_sk([x_obs' y_obs'],v_obs',[x(i) y(i)],V);
 [v1(i),va1(i),lambda_ok,d_mean]=krig_ok([x_obs],v_obs,[x(i)],V1,1);
 [v2(i),va2(i),lambda_ok,d_mean]=krig_ok([x_obs],v_obs,[x(i)],V2,1);
 [v3(i),va3(i),lambda_ok,d_mean]=krig_ok([x_obs],v_obs,[x(i)],V1,1,.3);
 [v4(i),va4(i),lambda_ok,d_mean]=krig_ok([x_obs],v_obs,[x(i)],V4,1);
 
end

[sv1,d]=semivar_synth(V1,[0:.01:3]);
[sv2,d]=semivar_synth(V2,[0:.01:3]);
[sv4,d]=semivar_synth(V4,[0:.01:3]);
sv3=sv1;
sv3(1)=0.3;

figure(1)
ax=[-.1 2.1 -.1 1.1];
subplot(2,4,1);plot(d,sv1,'ko');title(['A: ',format_variogram(V1,1)])
subplot(2,4,2);plot(d,sv2,'ro');title(['B: ',format_variogram(V2,1)])
subplot(2,4,3);plot(d,sv3,'bo');title(['C: ',format_variogram(V1,1),' Cd=0.3'])
subplot(2,4,4);plot(d,sv4,'bo');title(['D: ',format_variogram(V4,1)])
subplot(2,4,5);plot(d,1-sv1,'ko');title(['A: ',format_variogram(V1,1)])
subplot(2,4,6);plot(d,1-sv2,'ro');title(['B: ',format_variogram(V2,1)])
subplot(2,4,7);plot(d,1-sv3,'bo');title(['C: ',format_variogram(V1,1),' Cd=0.3'])
subplot(2,4,8);plot(d,1-sv4,'bo');title(['D: ',format_variogram(V4,1)])

for i=1:8,
  subplot(2,4,i);
  axis(ax);
  xlabel('distance');
end
for i=1:4, subplot(2,4,i);ylabel('Semivariogram'); end
for i=5:8, subplot(2,4,i);ylabel('Covariance'); end

suptitle('Varogram/Covariance models for nugget test')
print -dpng Example_NuggetEffectCovModels.png


figure(2)
subplot(2,1,1)
old on
plot(x,v1,'k-','LineWidth',1)
plot(x,v2,'r-','LineWidth',1)
plot(x,v3,'b-','LineWidth',1)
plot(x,v4,'g--','LineWidth',1)
hold off
legend('Observed data',['A: ',format_variogram(V1,1)],...
       ['B: ',format_variogram(V2,1)], ...
       ['C: ',format_variogram(V1,1),' --- Cd = 0.3'],...
       ['D: ',format_variogram(V4,1)],-1)

xlabel('X');ylabel('Kriging mean')

subplot(2,1,2)
plot(x,(va1),'k-','LineWidth',1)
hold on
plot(x,(va2),'r-','LineWidth',1)
plot(x,(va3),'b-','LineWidth',1)
plot(x,(va4),'g-','LineWidth',1)
hold off

xlabel('X');ylabel('Kriging variance')

legend(['A: ',format_variogram(V1,1)],['B: ',format_variogram(V2,1)], ...
       ['C :',format_variogram(V1,1),' --- Cd = 0.3'], ...
       ['D :',format_variogram(V4,1)],-1)


print -dpng Example_NuggetEffectProfile.png
