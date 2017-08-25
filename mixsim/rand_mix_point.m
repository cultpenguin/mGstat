function r=rand_mix_point(var1,m1,var2,m2,var3,m3,doplot)

% Draws a realization from a distribution of the following form:
% f(x)=N(m1,var1)*N(m2,var2)/N(m3,var3), where N referres to a normal
% distribution.
if nargin<7
    doplot=0;
end

a=m3-5*sqrt(var3); % Minimum proposed x value
b=m3+5*sqrt(var3); % Maximum proposed x value

xx=linspace(a,b,(b-a)*100); %a:abs(a)*0.1:b;
pp=exp(-0.5.*(xx-m1).^2./var1).*exp(-0.5.*(xx-m2).^2./var2)./exp(-0.5.*(xx-m3).^2./var3);
[p_max,pos_max]=max(pp);
%a=pos_max-3*sqrt(var3); % Minimum proposed x value
%b=pos_max+3*sqrt(var3); % Maximum proposed x value


if doplot==1
     figure,plot(xx,pp)
     r=[];
     keyboard
end

c=0;
while c==0 % Continue until a single realization is found
    x = a + (b-a).*rand;
    p=exp(-0.5*(x-m1)^2/var1)*exp(-0.5*(x-m2)^2/var2)/exp(-0.5*(x-m3)^2/var3);
    
    % Decide if the proposed x value should be accepted as a realization
    % from the probabiltiy distribution
    if rand<p/p_max;
        c=c+1;
        r=x;
    end
end