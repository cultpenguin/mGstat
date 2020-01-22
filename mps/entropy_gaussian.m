function H=entropy_gaussian(Cm);
n=size(Cm,1);
H=(n/2)*(1+log(2*pi))+0.5*logdet(Cm);
%H=(n/2)*log(2*pi*exp(1))+0.5*logdet(Cm); 
%H=0.5*logdet(2*pi*exp(1)*Cm);