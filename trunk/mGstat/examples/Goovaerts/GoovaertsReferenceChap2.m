% Goovaerts Example : Chapter 2
%

% load data
[p,pHeader]=read_eas('prediction.dat');
[t,tHeader]=read_eas('transect.dat');
[v,vHeader]=read_eas('validation.dat');

%
x=p(:,1)
y=p(:,2);
% list of continous and discrete data
icon=[5:11];
idis=[3:4];


figure(1)
% PLOT prediction AND validation DATA
plot(x,y,'ko'); % plot with black circles
hold on % make sure the current plot is not erased
plot(v(:,1),v(:,2),'g.','MarkerSize',15); % plot with green DOTS
hold off
axis equal % makes sure x- and y-axis use same scale
legend('Prediction','Validation')
% print -dpng f1_1.png


figure(2);
iidis=3;
ndata=size(p,1);
sk=[1 2 3 4 5];
h=hist(p(:,iidis),sk)
cdf=cumsum(h)./ndata;
pdf=h./ndata;
subplot(1,2,1),
bar(sk,cdf)
xlabel('s_k');ylabel('pdf')
title(pHeader(iidis))
subplot(1,2,2),
bar(sk,pdf)
title(pHeader(iidis))
xlabel('s_k');ylabel('cdf')
%print -dpng DiscreteUniv.png

figure(3);
iicon=5;
ndata=size(p,1);
sk=linspace(min(p(:,5)),max(p(:,5)),10);
h=hist(p(:,iicon),sk)
cdf=cumsum(h)./ndata;
pdf=h./ndata;
x_pdf_direct=sort(p(:,5));
y_pdf_direct=[1:1:ndata]./ndata;
subplot(1,2,1),
bar(sk,cdf)
hold on
plot(sort(p(:,5)),[1:1:ndata]./ndata,'r.')
hold off
xlabel('s_k');ylabel('pdf')
title(pHeader(iicon))
subplot(1,2,2),
bar(sk,pdf)
title(pHeader(iicon))
xlabel('s_k');ylabel('cdf')
%print -dpng ContUniv.png




% ALL 
figure
for i=1:length(icon)
  subplot(4,3,i)
  hist(p(:,icon(i)),20)
  title(pHeader(icon(i)))
end
suptitle('Cont. Histograms')
%print -dpng HistCont.png

figure
for i=1:length(idis)
  subplot(2,1,i)
  hist(p(:,idis(i)),20)
  title(pHeader(idis(i)))
end
suptitle('Discrete Histograms')

figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% location Maps
icon=5;
x=p(:,1);
y=p(:,2);
val=p(:,icon);x

dmin=min(val);
dmax=max(val);
colorax=[dmin dmax];
scatter(x,y,40,val)
% flip y-axis
%set(gca,'ydir','reverse')
% Makes sure axes are proportional
axis image ; 
title(pHeader{icon})

% Vis summary statistics med 2 decimaler
disp(['SUMMARY STATISTICS for ',pHeader{icon}])
disp(sprintf('Mean  =%5.2f',mean(val)))
disp(sprintf('Median=%5.2f',median(val)))
disp(sprintf('Min   =%5.2f',min(val)))
disp(sprintf('Max   =%5.2f',max(val)))
disp(sprintf('Std   =%5.2f',std(val)))
skew = 1/ndata * sum((val-mean(val)).^3)./var(val).^3;
skew = 1/ndata * sum(((val-mean(val)).^3)./(var(val).^3));
disp(sprintf('Skew  =%5.2f',skew ))
  

% CONDITIONAL 
iidis=3;
iicon=5;

disval=p(:,iidis);
conval=p(:,iicon);
z=linspace(min(conval),max(conval),10);

for i=unique(disval)'
  DatInGroup=find(disval==i);
  nD=length(DatInGroup);

  h=hist(p(DatInGroup,icon),z);
  cdf=cumsum(h)./nD;
  pdf=h./nD;

  subplot(2,2,i)
  bar(z,cdf);
  title([pHeader{icon},' conditional to ',pHeader{iidis},'=',num2str(i)])
 
end
%print -dpng UnivCond.png


icon=[5:11];
[hc,garr,h,gamma]=semivar_exp([x y],p(:,icon));
figure
for i=1:length(icon )
  subplot(3,3,i)
  plot(h,gamma(:,i),'.','MarkerSize',.1);
  xlabel('Distance')
  ylabel('\gamma')
  title(pHeader{icon(i)})
end  
suptitle('SemiVariogram Clouds - Continous data')
%print -dpng Goov2SemivarCloudCont.png

figure
for i=1:length(icon) 
  subplot(3,3,i)
  plot(hc,garr(:,i),'-*','MarkerSize',5);
  xlabel('Distance')
  ylabel('\gamma')
  title(pHeader{icon(i)})
end  
suptitle('Experimental semiovariogram - Continous data')
%print -dpng Goov2SemivarExpCon.png


% INDICATOR SEMIVARIOGRAM

for iidis=idis
  figure
  indic=unique(p(:,iidis));
  for ind=1:length(indic);
    d=zeros(length(x),1);
    % find indicators of current types
    d(find(p(:,iidis)==indic(ind)))=1;
    [ihc,ighc,ih,igamma]=semivar_exp([x y],d);
    subplot(length(indic),1,ind)
    plot(ihc,ighc,'-*')
    title(num2str(indic(ind)))
  end
  suptitle(['indicator semivariogram - discrete data ',pHeader{iidis}])
  %eval(['print -dpng GoovChap2IndSemiVar',pHeader{iidis},'.png']);
end


% INDICATOR FOR Cd
clear ighc
ival=5;
val=p(:,ival);
hval=pHeader{ival};
ithres=[.56,.80,1.38,1.88];
nt=length(ithres);
for i=1:length(ithres)
  d=zeros(length(x),1);
  % find indicators of current types
  d(find(val<=ithres(i)))=1;
  
  [ihc,ighc(i,:)]=semivar_exp([x y],d);
  
  subplot(ceil(nt/2),ceil(nt/2),i)
  scatter(x,y,40,d,'filled')
  axis image
  title(['thres=',num2str(ithres(i)),'ppm - ',hval])

  L{i}=num2str(ithres(i))
  
end
print -dpng Goov2IndTransformArea.png
figure
plot(ihc,ighc,'-')
legend(L)
xlabel('distance')
ylabel('\gamma')
title(['Omnidirectional semivariogram for indicator transforms of ',hval])
%print -dpng Goov2IndTransform.png


%%%% 
% DIRECTIONAL SEMIVARIOGRAM
h_array=linspace(0,1.8,14);
nang=4;
[hc,garr,h,gamma,hangc]=semivar_exp([x y],p(:,icon),h_array,nang);
for i=1:nang
  L{i}=num2str(180*hangc(i)./pi)
end


for i=1:length(icon)
  %subplot(length(icon),1,i)
  figure;
  plot(hc,garr(:,:,i),'-','linewidth',2);
  title(pHeader{icon(i)})
  xlabel('distance')
  ylabel('\gamma')
  legend(L)
  eval(['print -dpng GoovChap2SemivarDirectional_',pHeader{icon(i)},'.png']);
end


% H SCATTERGRAM
[hc,garr,h,gamma,hangc,zh,zt]=semivar_exp([x y],p(:,icon(1)));

dh=.1;
i=0;
for ih=[.043 .214 .388 .616 .787 1.024];
  i=i+1;
  ii=find( h>(ih-dh) & h< (ih+dh));
  subplot(2,3,i)
  plot(zh(ii,1),zt(ii,1),'k.','MarkerSize',.2)
  title(['h=',num2str(ih),' \pm ',num2str(dh)])
  xlabel('Head')
  ylabel('Tail')
  axis([0 max(h) 0 max(h)])
  hold on
  plot([0 max(h)],[0 max(h)],'r-','linewidth',4)
  hold off
  axis image
end
suptitle(pHeader(icon(1)))
print -dpng GoovChap2Hscatter.png
