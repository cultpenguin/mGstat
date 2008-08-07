[data,header]=read_eas('prediction.dat');

iatt=5;
x_obs=data(:,1);
y_obs=data(:,2);
v_obs=data(:,iatt);

% THRESHOLD
v_threshold=0.8;

[v_ind]=indicator_transform_con(v_obs,v_threshold);

figure(1)
subplot(1,2,1)
S=v_obs-min(v_obs);S=S./max(S);
scatter(x_obs,y_obs,S*90+10,v_obs,'filled')
caxis([min(v_obs) v_threshold])
colormap jet
xlabel('X'),ylabel('Y');title(['Orig ',header{iatt},' data'])
ax=axis;
axis image
colorbar
subplot(1,2,2)
for i=1:length(v_obs)

  if v_ind(i)==0,
    col=[1 0 0];
  else
    col=[0 0 0];
  end
  text(x_obs(i),y_obs(i),num2str(v_ind(i)),'FontSize',7,'color',col)
  axis(ax)
  hold on
end
hold off
%scatter(x_obs,y_obs,30,v_ind)
xlabel('X'),ylabel('Y');
title(['Ind Transformed Prob(',header{iatt},'<',num2str(v_threshold),')'])
axis image

print -dpng CdInd_A.png

% WRITE DATA TO DISK
write_eas('GoovaertsChap7_IC_Cd.eas',[x_obs,y_obs,v_ind]);

gstat_par='GoovaertsChap7_IC_Cd.cmd';
G=read_gstat_par(gstat_par);
%G.mask{1}.file='JuraMask_0_1.asc';
G.mask{1}.file='JuraMask_0_05.asc';

[mask,x,y,dx,nanval,x0,y0,xll,yll]=read_arcinfo_ascii(G.mask{1}.file);

usemax=40;
% SETUP AND PERFORM SIMPLE KRIGING
G.data{1}.max=usemax;
G.data{1}.sk_mean=mean(v_ind);
[pred_sk,var_sk]=mgstat(G);

% SETUP AND PERFORM ORDINARY KRIGING
G.data{1}.max=usemax;
G.data{1}=rmfield(G.data{1},'sk_mean');
[pred_ok,var_ok]=mgstat(G);


varmax=0.9.*max(var_sk{1}(:));
alphamask=zeros(size(var_sk{1}));
alphamask(find(var_sk{1}<varmax))=1;
figure(2);
subplot(1,2,1)
imagesc(x,y,pred_sk{1})
alpha(alphamask)
hold on;scatter(x_obs,y_obs,40,v_ind,'filled');hold off

caxis([0 1])
set(gca,'Ydir','normal')
axis image
title('SIMPLE KRIGING')

subplot(1,2,2)
imagesc(x,y,pred_ok{1})
alpha(alphamask)
caxis([0 1])
hold on;scatter(x_obs,y_obs,40,v_ind,'filled');hold off
set(gca,'Ydir','normal')
axis image
title('ORDINARY KRIGING')

suptitle(['Kriging results for Prob(',header{iatt},'<',num2str(v_threshold),')'])

print -dpng CdInd_B.png
