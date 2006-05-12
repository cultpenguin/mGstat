function [P,Pall]=visim_calc_semivar_prob(g_pdf,g_arr,hc,g)
% [P,Pall]=visim_calc_semivar_prob(g_pdf,g_arr,hc,g)

for i=1:length(hc)
%  disp(sprintf('CENTER %4.2f',hc(i)))
  
  pdf=g_pdf(:,i)';
  
  Pall(i)=interp1(g_arr,pdf,g(i),'nearest');  

end

%P=sum(Pall)./length(hc);
Pall(find(Pall==0))=realmin;
P=sum(log(Pall));

%P=comb_cprob_nd(.1,Pall(2:length(Pall)));


%P=prod(Pall);