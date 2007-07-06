% Example_GstatIndicatorKriging
%
%parfile='gstat_indicator_cokriging.cmd';
parfile='gstat_indicator_kriging.cmd';
G=read_gstat_par(parfile);

[pred,pvar]=mgstat(G);

for i=1:length(pred)
  
  % MASK BORDER VALUES
  p=pred{i};
  p(find(pvar{1}>.2))=NaN;
  
  figure(1)
  subplot(2,2,i)
  imagesc(p)
  axis image
  caxis([0 1])
  set(gca,'ydir','normal')
  title(sprintf('Threshold Value , prob(Z<%5.2g)',G.data{i}.I))
  colorbar
  
  figure(2)
  subplot(2,2,i)
  imagesc(pvar{i})
  axis image
  colorbar
  set(gca,'ydir','normal')
  
end

figure(1);  suptitle('IK PREDICTIONS')
figure(2);  suptitle('IK VARIANCES')
