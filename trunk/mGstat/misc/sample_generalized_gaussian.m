function d_test = sample_generalized_gaussian(d,step,d0,sigma,p);

if nargin<5, p=2; end

if nargin==0;
    
    d0=10;sigma=5;p=2;step=2;
    N=10000;d=zeros(N,1);d(1)=10;
    for i=2:N;
        d(i)=sample_generalized_gaussian(d(i-1),step,d0,sigma,p);
    end
    d_test=d;
    hist(d_test);
    return
end

L_init=generalized_gaussian(d,d0,sigma,p);

acc=0;
while acc==0
    
    d_test = d + randn(1)*step;
    L_test = generalized_gaussian(d_test,d0,sigma,p);

    P_acc = L_test/L_init;
    
    if P_acc>rand(1)
        % ACCEPT
        break;
    end

end
    
