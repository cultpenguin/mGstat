function H=entropy_gaussian(Cm);
n=size(Cm,1);
H=(n/2)*(1+log(2*pi))+0.5*logdet(Cm);