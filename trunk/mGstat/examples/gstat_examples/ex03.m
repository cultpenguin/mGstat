% ex03 : gstat example ex03.cmd
cmd_file='ex03';
[pred,pred_var,pred_covar,mask,G]=gstat(sprintf('%s.cmd',cmd_file));

[obs,obs_header,obs_title]=read_eas(G.data{1}.file);

figure(3);clf;
imagesc(mask.x,mask.y,pred(:,:,1));

hold on
plot(obs(:,1),obs(:,2),'k.','MarkerSize',10);
scatter(obs(:,1),obs(:,2),10,obs(:,3));
hold off
axis image
cb=colorbar;
set(get(cb,'Ylabel'),'string',obs_header{3})
title(sprintf('GSTAT %s.cmd - %s',cmd_file,obs_title))
xlabel(obs_header{1})
ylabel(obs_header{2})

print('-dpng',sprintf('%s.png',cmd_file))