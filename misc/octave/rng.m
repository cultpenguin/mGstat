function rng(x)
  if nargin<1
    x=1;
  end
  if ischar(x);
    disp(sprintf('''%s'' not supported as input argument in this rng/octave',x))
    return
  end
  
  randn("seed",x)
  rand("seed",x)
end
