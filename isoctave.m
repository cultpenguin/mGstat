% isoctave : checks of octave
function r=isoctave
  v=version;

  if isempty(strfind(v,'R'))
      r=1;
  else
      r=0;
  end
