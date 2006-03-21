% visim_semivar_pdf

ng_arr=20;
g_arr=linspace(0,2*V.gvar,ng_arr);
g_exp=g{1};
h_exp=hc{1};
nh=length(h_exp) ;        

g_pdf=zeros(nh,ng_arr)';

for i=1:nh
  [lpdf]=hist(g_exp(i,:),g_arr);
  g_pdf(:,i)=lpdf(:)./sum(lpdf);
end
   
% CUMULATIVE PDF
g_cpdf=cumsum(g_pdf);

%quan=0.01;
for i=1:nh
  i_lower=find(g_cpdf(:,i)>quan);
  if isempty(i_lower),
    i_lower=1;
  else
    i_lower=i_lower(1);
  end
  i_upper=find(g_cpdf(:,i)<(1-quan));
  if isempty(i_upper),
    i_upper=1;
  else
    i_upper=min([i_upper(length(i_upper))+1,ng_arr]);
  end

  g_lower(i)=g_arr(i_lower);
  g_upper(i)=g_arr(i_upper);
end
  
  
imagesc(h_exp,g_arr,g_pdf)
set(gca,'ydir','normal')
caxis([0 .2])
colormap(1-gray)
hold on
plot(h_exp,g_lower,'r-*','LineWidth',3)
plot(h_exp,g_upper,'r--','LineWidth',3)
hold off
l1=sprintf('q_{%4.2f} %%',100*quan);
l2=sprintf('q_{%4.2f}',100*(1-quan));
legend(l1,l2)