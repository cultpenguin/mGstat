% inverse normal score transform
function d_out=inscore(d,normalscore,origdata)
  d_out=interp1(normalscore,sort(origdata),d);