% ex09 : gstat example ex09.cmd
cmd_file='ex09';
disp(sprintf('%s : There (seems to be) a bug in GSTAT setting NCOLUMNS = 6, when there is only 5 columes in the output EAS file',mfilename)); 
[pred,pred_var,pred_covar,mask,G]=gstat(sprintf('%s.cmd',cmd_file));
