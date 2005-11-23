mgstat_convert('mask_map');
mgstat_convert('part_a');
mgstat_convert('part_b');
mgstat_convert('sqrtdist');

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
mgstat_plot('ex03.cmd');
figure;
mgstat_plot('ex05.cmd');
figure;
mgstat_plot('ex07.cmd');
figure;
mgstat_plot('ex08.cmd');
figure;
mgstat_plot('ex10.cmd');
figure;
mgstat_plot('ex11.cmd');
figure;
mgstat_plot('ex12.cmd');
figure;
mgstat_plot('ex13.cmd');
figure;
mgstat_plot('ex14.cmd');
figure;
mgstat_plot('ex15.cmd');
figure;
mgstat_plot('ex16.cmd');
figure;
mgstat_plot('ex17.cmd');
