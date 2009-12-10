cmd_file='ex10';
[pred,pred_var,pred_covar,mask,G]=gstat(sprintf('%s.cmd',cmd_file));


[obs1,obs_header1,obs_title1]=read_eas(G.data{1}.file);
[obs2,obs_header2,obs_title2]=read_eas(G.data{2}.file);

for i=1:2;
    if (isfield(G.data{i},'log')); pred(:,:,i)=exp(pred(:,:,i));end
end

clf;
subplot(2,2,1);
imagesc(mask.x,mask.y,pred(:,:,1));axis image;title([G.predictions{1}.data,' mean estimate'])
hold on
plot(obs1(:,1),obs1(:,2),'k.','MarkerSize',12);
scatter(obs1(:,1),obs1(:,2),10,obs1(:,G.data{1}.v),'filled');
hold off
axis image
cb=colorbar;
set(get(cb,'Ylabel'),'string',obs_header1{3})
xlabel(obs_header1{1})
ylabel(obs_header1{2})

subplot(2,2,2);
imagesc(mask.x,mask.y,pred(:,:,2));axis image;title([G.predictions{2}.data,' mean estimate'])
hold on
plot(obs2(:,1),obs2(:,2),'k.','MarkerSize',12);
scatter(obs2(:,1),obs2(:,2),10,obs1(:,G.data{2}.v),'filled');
hold off
axis image
cb=colorbar;
set(get(cb,'Ylabel'),'string',obs_header2{3})
xlabel(obs_header2{1})
ylabel(obs_header2{2})

subplot(2,2,3);
imagesc(mask.x,mask.y,pred_var(:,:,1));axis image;
colorbar
title([G.predictions{1}.data,' variance estimate'])

subplot(2,2,4);
imagesc(mask.x,mask.y,pred_var(:,:,2));axis image;
colorbar
title([G.predictions{1}.data,' variance estimate'])


watermark(sprintf('GSTAT %s.cmd - %s',cmd_file,G.mgstat.comment{2}));

print('-dpng',sprintf('%s',cmd_file))