% ex06 : gstat example ex06.cmd
cmd_file='ex06';
[pred,pred_var,pred_covar,mask,G]=gstat(sprintf('%s.cmd',cmd_file));
figure(6),clf;
imagesc(mask.x,mask.y,pred(:,:,1));
cb=colorbar;
axis image
title('Unconditional Gaussian simulation')
watermark(sprintf('GSTAT %s.cmd - %s',cmd_file,G.mgstat.comment{2}));

print('-dpng',sprintf('%s.png',cmd_file))