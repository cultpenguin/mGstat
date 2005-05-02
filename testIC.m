[pred,pvar]=mgstat('testIC.cmd');
G=read_gstat_par('testIC.cmd')

for i=1:9, 
  subplot(3,3,i);
  imagesc(pred{i}),
  axis image;
  set(gca,'Ydir','normal');
  title(G.data{i}.I)
end

% LAEG PREDIKTIONER IND I 3D MATRICE
for i=1:9, pm(:,:,i)=pred{i};end
for i=1:9, vm(:,:,i)=pvar{i};end

% FIND THRESHOLDS
for i=1:9, thres(i)=G.data{i}.I;end


figure
plot(thres,squeeze(pm(30,25,:)),'k-*')
hold on
plot(thres,squeeze(vm(30,25,:)),'r-*')
hold off
legend('Pred','Var')
