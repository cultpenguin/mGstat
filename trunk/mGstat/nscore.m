function [d_nscore,normscore,pk]=nscore(d)

d=d(:);
n=length(d);

id=[1:n]';


%Calculte normal scores
pk=id./n-.5/n;
normscore=norminv(pk);
sd=sort(d);

%
s_sort=sortrows([d id]);

d_nscore=0.*d;
d_nscore(s_sort(:,2))=normscore;

% add random noise 
sd=rand(size(sd)).*.01+sd;

subplot(3,1,1)
plot(sd,id./n)
subplot(3,1,2)
plot(normscore,id./n)
subplot(3,1,3)
plot(d,d_nscore,'.')


