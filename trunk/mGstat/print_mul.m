% print both EPS and PNG files
function print_mul(fname);

  print(gcf, '-dpng', fname )

  print(gcf, '-depsc2', fname )
  
  trim_cmd='/home/tmh/bin/trim_image';
  
  if exist(trim_cmd)==2
    system(sprintf('%s %s.png',trim_cmd,fname));
  end
  