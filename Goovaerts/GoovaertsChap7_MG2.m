% GoovaertsChap7_MG2 : MultiGaussian Approach
% read data
[data,header]=read_eas('transect.dat');
[pdata,pheader]=read_eas('prediction.dat');



%%% 
% EXAMPLE OF NORMAL SCORE TRANSFORMATION GAUSSIAN PDF AND BACK
%
if exist('useEx')==0
  % IF NO SELECTION OF useEx has been made, choose a default
  useEx=1;
end
if useEx==1,
  % DATA WITH REAL GAUSSIAN SITRIBUITION
  nd=10000;
  d=randn(1,nd)+10;
elseif useEx==2,
  % SPARSE DATA FROM TRANSECT.DAT
  id=find(data(:,4)~=-99);
  d=data(id,4); 
  nd=length(d);
  %d(find(d<0))=0;
else
  % ALL DATA FROM PREDICTION.DAT
  d=pdata(:,5);
  nd=length(d);
end

% normal score transform
[d_nscore,normscore,pk]=nscore(d);

subplot(3,2,1)
plot(sort(d),[1:nd]./nd,'b.')
title('ORIGINAL A PRIORI DATA CDF')
grid on
subplot(3,2,2)
plot(sort(d_nscore),[1:nd]./nd,'ro')
title('ORIGINAL A PRIORI NORMAL SCORE CDF')
grid on

hx=linspace(min(d),max(d),60);
hxn=linspace(-4,4,60);

% NOW SELECT A GAUSSIAN MODEL IN THE NORMAL SCORE SAPCE


for kmean=linspace(min(d_nscore),max(d_nscore),100);
 kvar=.8;
  
  
  post_cdf = normcdf(hxn,kmean,kvar);
  post_pdf = normpdf(hxn,kmean,kvar);
  kmean_inscore = inscore(kmean,normscore,d);
  kvar_inscore = inscore(kvar,normscore,d)-mean(d);

  hx_inscore=inscore(hxn,normscore,d);
  post_cdf_in = normcdf(hx,kmean_inscore,kvar_inscore);
  post_pdf_in = normpdf(hx,kmean_inscore,kvar_inscore);
  
  subplot(3,2,4)
  plot(hxn,post_cdf,'r')
  title(sprintf('NSCORE CDF mean=%4.2g',kmean))
  ylabel('Prob(Z<z)')
  subplot(3,2,6)
  plot(hxn,post_pdf,'r')
  title(sprintf('NSCORE Posterior PDF, mean=%3.2g var=%3.1g',kmean,kvar))
  
  subplot(3,2,3)
  plot(hx_inscore,post_cdf,'b-',hx,post_cdf_in,'k-')
  title(sprintf('Posterior CDF mean=%4.2g',kmean_inscore))
  ylabel('Prob(Z<z)')
  legend('NSCORE','DIRECT',4)
  
  subplot(3,2,5)
  plot(hx_inscore,post_pdf,'b-',hx,post_pdf_in,'k-')
  title(sprintf('Posterior PDF, mean=%5.2f, var=%5.2f',kmean_inscore,kvar_inscore))
  legend('NSCORE','DIRECT')
  
  drawnow
  pause(.1)

end
