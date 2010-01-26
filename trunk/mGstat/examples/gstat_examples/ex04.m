% ex04 : gstat example ex04.cmd
cmd_file='ex04';
[pred,pred_var,pred_covar,mask,G]=gstat(sprintf('%s.cmd',cmd_file));

[out,out_header,out_title]=read_eas(G.set.output);
[obs,obs_header,obs_title]=read_eas(G.data{1}.file);

figure(4);clf;
scatter(obs(:,1),obs(:,2),10,obs(:,3));
hold on
plot(out(:,1),out(:,2),'k.','MarkerSize',12);
scatter(out(:,1),out(:,2),10,out(:,3));
hold off
axis image
cb=colorbar;
set(get(cb,'Ylabel'),'string',obs_header{3})
title(sprintf('GSTAT %s.cmd - %s',cmd_file,obs_title))
xlabel(obs_header{1})
ylabel(obs_header{2})

print('-dpng',sprintf('%s.png',cmd_file))