% sperical_spreading(r,type);
function A=spherical_spreading(r,m);
  if nargin==1
    m=1;
  end
    
  A=(1./r).^m;