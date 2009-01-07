function [d_test,L_true,d_true] = sample_generalized_gaussian(d,step,d0,sigma,p,L_init);

if nargin<5, p=2; end

if nargin==0;
    p=100;
    step=4;
    d0=10;sigma=4;
    N=300000;
    d=zeros(N,1);d(1)=d0;

    d_true=linspace(d0-4*sigma,d0+4*sigma,250);
    L_true = generalized_gaussian(d_true,d0,sigma,p);

    for i=2:N;
        d(i)=sample_generalized_gaussian(d(i-1),step,d0,sigma,p);
        d_plot=5000;
        if (i/d_plot)==round(i/d_plot)
            h=hist(d(1:i),d_true);
            L_sim=sum(L_true)*h./sum(h);
            subplot(1,2,1);
            plot(d_true,L_true,'k.',d_true,L_true,'k-',d_true,L_sim,'r-');
            set(gca,'Ylim',[0 1.4*max(L_true)])
            title(sprintf('%7d of %7d',i,N))
            subplot(1,2,2);
            plot(d_true,cumsum(L_true),'k-',d_true,cumsum(L_sim),'r-');
            set(gca,'Ylim',[0 1.4*max(cumsum(L_true))])
            drawnow;
        end
    end
    figure;hist(d,100);

    d_test=d;
    
    return
end


if nargin<6
    L_init=generalized_gaussian(d,d0,sigma,p);
end

acc=0;
while acc==0

    d_test = d + randn(1)*step;
    %d_test = d + (rand(1)-.5)*(step);
    
    L_test = generalized_gaussian(d_test,d0,sigma,p);

    % meth1
    %   P_acc = L_test/L_init;
    % meth2
    P_acc = exp(log(L_test)-log(L_init));
    if P_acc>rand(1)
        % ACCEPT
        break;
    end

end

