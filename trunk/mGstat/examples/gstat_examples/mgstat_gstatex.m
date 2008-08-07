gstat_convert('mask_map');
gstat_convert('part_a');
gstat_convert('part_b');
gstat_convert('sqrtdist');

if isunix
  unix('cp mask_map.ascii mask_map');
  unix('cp part_a.ascii part_a');
  unix('cp part_b.ascii part_b');
  unix('cp sqrtdist.ascii sqrtdist');
else
  dos('copy mask_map.ascii mask_map');
  dos('copy part_a.ascii part_a');
  dos('copy part_b.ascii part_b');
  dos('copy sqrtdist.ascii sqrtdist');
end  


figure;
gstat_plot('ex03.cmd');
figure;
gstat_plot('ex05.cmd');
figure;
gstat_plot('ex07.cmd');
figure;
gstat_plot('ex08.cmd');
figure;
gstat_plot('ex10.cmd');
figure;
gstat_plot('ex11.cmd');
figure;
gstat_plot('ex12.cmd');
figure;
gstat_plot('ex13.cmd');
figure;
gstat_plot('ex14.cmd');
figure;
gstat_plot('ex15.cmd');
figure;
gstat_plot('ex16.cmd');
figure;
gstat_plot('ex17.cmd');
