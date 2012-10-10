% CreateMisfitFunction : Dynamically created function to be used for
%                        semivariogram optimization
function CreateMisfitFunction(V,h,mat)
  
  
  fid=fopen('GstatOptim.m','w');
  
  
  fprintf(fid,'function err=GstatOptim(x)\n');

  fprintf(fid,'load %s\n',mat);
  fprintf(fid,'sv_calc=0.*h;\n');;
  for iv=1:length(V);
    fprintf(fid,'V(%d).type=''%s'';\n',iv,V(iv).type);
    fprintf(fid,'V(%d).par1=x(%d);\n',iv,(iv-1)*2+1);
    fprintf(fid,'V(%d).par2=x(%d);\n',iv,(iv-1)*2+2);
  end
  fprintf(fid,'sv_synth=semivar_synth(V,h);\n\n');
  fprintf(fid,'nn=find(~isnan(sv_obs));\n');
  fprintf(fid,'err=sum(sqrt((sv_synth(nn)-sv_obs(nn)).^2));\n');
  
  fclose(fid);
  
  