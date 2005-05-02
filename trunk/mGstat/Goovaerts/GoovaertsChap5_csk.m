% GoovaertsChap5_csk : Goovaerts Example : Chapter 5 Simple CoKriging

[data,header]=read_eas('transect.dat');

x=data(:,1);
d1=data(:,4);
d2=data(:,5);

% find data
id1=find(d1~=-99);
%id1=id1([1 10]); % UNCOMMENT LINE TO USE ONLY 2 PRIMARY DATA
x_obs1=x(id1);
v_obs1=d1(id1);
nobs1=length(x_obs1);
v_mean1=mean(v_obs1);

id2=find(d2~=-99);
id2=id1; % UNCOMMENT LINE TO USE ONLY DATA COLOCATED (SAME LOCATION)
%            TO THE PRIMARY DATA (nPrimary=nSecondary)
x_obs2=x(id2);
v_obs2=d2(id2);
nobs2=length(x_obs2);
v_mean2=mean(v_obs2);


% SELECT ARRAY OF X-VALUES FOR WHICH TO CALCULATE
% KRIGING ESTIMATES
%x=[min(x):.01:max(x)];
%x=linspace(min(data(:,1)),max(data(:,1)),1001);
%x=[0:.05./5:7];
nx=length(x); % SAME AS GOOVAERTS


% GOOV P 211
V1s='0.3 Nug(0) + 0.3 Sph(0.2) + 0.26 Sph(1.3)';
V2s='11 Nug(0) + 71 Sph(1.3)';
V12s='0.6 Nug(0) + 3.8 Sph(1.3)';
% TRANSFORM VARIOGRAM STRINGS INTO MATLAB STRUCTURE
% INcreases performance, but not mandatory.
V1=deformat_variogram(V1s);
V2=deformat_variogram(V2s);
V12=deformat_variogram(V12s);

figure(1)
xv=[0:.01:2];
subplot(2,2,1);
plot(xv,semivar_synth(V1,xv))
title(['V11 : ',V1s])
subplot(2,2,2);
plot(xv,semivar_synth(V12,xv))
title(['V12 : ',V12s])
subplot(2,2,3);
plot(xv,semivar_synth(V12,xv))
title(['V21 : ',V12s])
subplot(2,2,4);
plot(xv,semivar_synth(V2,xv))
title(['V22 : ',V2s])

figure(2)
[ax,h1,h2]=plotyy(x_obs1,v_obs1,x_obs2,v_obs2);
set(get(ax(1),'Ylabel'),'String','Primary Data')
set(get(ax(2),'Ylabel'),'String','Secondary Data')
xlabel('Offset [km]')
title('Data for CoKriging')
set(h1,'Marker','*')
set(h2,'Marker','o')


d_sk=zeros(size(x));
d_sk_var=zeros(size(x));
d_sck=zeros(size(x));
d_sck_var=zeros(size(x));
weight_mean1_sck=zeros(size(x));
weight_mean2_sck=zeros(size(x));
figure(3);
for i=1:length(x)
%for i=46
  [d_sck(i),d_sck_var(i),lambda_sk,Ksk,ksk]=cokrig_sk(x_obs1,v_obs1,x_obs2,v_obs2,x(i),V1,V2,V12,v_mean1,v_mean2);
  [d_sk(i),d_sk_var(i)]=krig_sk(x_obs1,v_obs1,x(i),V1,v_mean1);
  weight_mean1_sck(i)=1-sum(lambda_sk(1:nobs1));
  weight_mean2_sck(i)=-1.*sum(lambda_sk(nobs1+1:nobs1+nobs2));
  if ((i/10)==round(i/10)|(i==length(x))), 
    disp(sprintf('%d/%d',i,length(x))), 

    subplot(3,1,1)
    
    [ax,h1,h2]=plotyy(x_obs1,v_obs1,x_obs2,v_obs2);
    set(get(ax(1),'Ylabel'),'String','Primary Data')
    set(get(ax(2),'Ylabel'),'String','Secondary Data')
    xlabel('Offset [km]')
    title('Data for CoKriging')
    set(h1,'Marker','*')
    set(h2,'Marker','o')
    
    
    subplot(3,1,2)
    plot(x,d_sck,'b-',x,d_sk,'g-','linewidth',2);
    hold on  
    %plot(x,[d_sck-d_sck_var,d_sck+d_sck_var],'b-',x,[d_sk-d_sk_var,d_sk+d_sk_var],'g-','linewidth',.1);
    plot(x_obs1,v_obs1,'k.','MarkerSize',20);
    hold off
    legend('SCK','SK')
    xlabel('x [km]')
    ylabel('data values')
    
    subplot(3,1,3)
    plot(x,weight_mean1_sck,'b-',x,weight_mean2_sck,'r-','linewidth',2);
    legend('Primary','Secondary')
    title('Weight Of Mean')
    xlabel('x [km]')
    ylabel('weight')
    drawnow
  end
end

print -dpng GoovaertsF6_8.png
eval(['print -dpng CoKrigP',num2str(nobs1),'S',num2str(nobs2),'.png']);
