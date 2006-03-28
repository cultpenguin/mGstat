function [g_pdf,g_arr,h_exp]=visim_semivar_pdf(g_exp,h_exp,g_max)

if nargin<3
  g_max=max(g_exp(:));
end

% visim_semivar_pdf

%g_max=2*V.gvar;
ng_arr=40;
g_arr=linspace(0,g_max,ng_arr);
% g_exp=g{1};
% h_exp=hc{1};
nh=length(h_exp) ;        

g_pdf=zeros(nh,ng_arr)';

for i=1:nh
  [lpdf]=hist(g_exp(i,:),g_arr);
  g_pdf(:,i)=lpdf(:)./sum(lpdf);
end
   
% CUMULATIVE PDF
g_cpdf=cumsum(g_pdf);

quan=[.1,.5,.9];
for j=1:length(quan);
  for i=1:nh
    i_lower=find(g_cpdf(:,i)>quan(j));
    if isempty(i_lower),
      i_lower=1;
    else
      i_lower=i_lower(1);
    end
    g_lower(i)=g_arr(i_lower);
  end
  q(j,:)=g_lower;
end
  
  
imagesc(h_exp,g_arr,g_pdf)
set(gca,'ydir','normal')
caxis([0 .1])
colormap(1-gray)
hold on
%plot(h_exp,g_lower,'r-*','LineWidth',3)
plot(h_exp,q,'r-*','LineWidth',1)
% plot(h_exp,g_upper,'r--','LineWidth',3)
hold off
%l1=sprintf('q_{%4.2f} %%',100*quan);
%l2=sprintf('q_{%4.2f}',100*(1-quan));
%legend(l1,l2)