function txt=format_variogram(V);
  
  txt=[''];
  for i=1:length(V)
    if i>1, txt=[txt,' + '];end
    txt=[txt,sprintf('%11.8f %s(%11.8f)',V(i).par1,V(i).type,V(i).par2)];
  end
  