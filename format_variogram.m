function txt=format_variogram(V);
  
  txt=[''];
  for i=1:length(V)
    if i>1, txt=[txt,' + '];end
    txt=[txt,sprintf('%7.4f %s(%7.4f)',V(i).par1,V(i).type,V(i).par2)];
  end
  