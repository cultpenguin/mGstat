cmd_file='ex04';
[pred,pred_var,pred_covar,mask,G]=gstat(sprintf('%s.cmd',cmd_file));

[out,out_header,out_title]=read_eas(G.set.output);
[obs,obs_header,obs_title]=read_eas(G.data{1}.file);


scatter(obs(:,1),obs(:,2),10,obs(:,3),'filled');
hold on
scatter(out(:,1),out(:,2),200*out(:,4),out(:,3),'k.');
scatter(out(:,1),out(:,2),10,out(:,3),'filled');
hold off
axis image
cb=colorbar;
set(get(cb,'Ylabel'),'string',obs_header{3})
title(sprintf('GSTAT %s.cmd - %s',cmd_file,obs_title))
xlabel(obs_header{1})
ylabel(obs_header{2})

print('-dpng',sprintf('%s',cmd_file))