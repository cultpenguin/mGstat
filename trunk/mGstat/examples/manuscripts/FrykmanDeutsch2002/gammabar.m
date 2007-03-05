% gammabar : numerical computation of the gammabar 
function gbar=gammabar(dx,V)

n=10;i=0;
for r1=linspace(0,dx,n)
for r2=linspace(0,dx,n)
     r2=dx;  
  i=i+1;
  h(i)=abs(r1-r2);
  gbar_small_r(i)=semivar_synth(V,h(i))./V.par1;

end
end
gbar=mean(gbar_small_r);
gbar=sum(gbar_small_r)./i;
