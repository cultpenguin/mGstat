cmd_file='ex07';
[pred,pred_var,pred_covar,mask,G]=gstat(sprintf('%s.cmd',cmd_file));


[obs,obs_header,obs_title]=read_eas(G.data{1}.file);

if (isfield(G.data{1},'log')); pred=exp(pred);end



clf;
imagesc(mask.x,mask.y,pred(:,:,1));

hold on
plot(obs(:,1),obs(:,2),'k.','MarkerSize',12);
scatter(obs(:,1),obs(:,2),10,obs(:,3),'filled');
hold off
axis image
cb=colorbar;
set(get(cb,'Ylabel'),'string',obs_header{3})
xlabel(obs_header{1})
ylabel(obs_header{2})


cb=colorbar;
axis image
title('Unconditional Gaussian simulation')
watermark(sprintf('GSTAT %s.cmd - %s',cmd_file,G.mgstat.comment{2}));

print('-dpng',sprintf('%s',cmd_file))