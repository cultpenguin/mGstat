% ex05 : gstat example ex05.cmd
cmd_file='ex05';
[pred,pred_var,pred_covar,mask,G]=gstat(sprintf('%s.cmd',cmd_file));

[obs,obs_header,obs_title]=read_eas(G.data{1}.file);

if (isfield(G.data{1},'log')); pred=exp(pred);end

figure(5);clf;
subplot(1,2,1);
imagesc(mask.x,mask.y,pred(:,:,1));
hold on
plot(obs(:,1),obs(:,2),'k.','MarkerSize',12);
scatter(obs(:,1),obs(:,2),10,obs(:,3));
hold off
axis image
cb=colorbar;
set(get(cb,'Ylabel'),'string',obs_header{3})
xlabel(obs_header{1})
ylabel(obs_header{2})
title('Mean')

subplot(1,2,2);
imagesc(mask.x,mask.y,pred_var(:,:,1));
colorbar
hold on
plot(obs(:,1),obs(:,2),'k.','MarkerSize',12);
hold off
axis image
%cb=colorbar;
%set(get(cb,'Ylabel'),'string',obs_header{3})
xlabel(obs_header{1})
ylabel(obs_header{2})
title('Variance')

watermark(sprintf('GSTAT %s.cmd - %s',cmd_file,G.mgstat.comment{2}));

print('-dpng',sprintf('%s.png',cmd_file))