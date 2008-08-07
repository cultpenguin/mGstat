% Goovaerts Example : Chapter 2, Bivariare analysis
%

% load data
[p,pHeader]=read_eas('prediction.dat');
[t,tHeader]=read_eas('transect.dat');
[v,vHeader]=read_eas('validation.dat');

%
x=p(:,1);
y=p(:,2);
% list of continous and discrete data
icon=[5:8];
idis=[3:4];
ncon=length(icon);
ndis=length(idis);

% Scattergram
nsc=sum([1:1:length((icon))-1]);
ncol=3;
i=0;
for i1=(1:ncon-1);
for i2=(i1+1:ncon);
  i=i+1;
  subplot(ceil(nsc/ncol),ncol,i)
  %subplot(ncon,ncon,(i1-1)*ncon+i2)
  d1=p(:,icon(i1));
  d2=p(:,icon(i2));
  % rank transform
  rd1=rank_transform(d1);rd2=rank_transform(d2);

  plot(d1,d2,'k.','MarkerSize',4)
  xlabel(pHeader{icon(i1)})
  ylabel(pHeader{icon(i2)})
  set(gca,'FontSize',6);
  % THE MATLAB BUILTIN ROUTINES
  % CORR COEFFICINT OF DATA
  %ccfM=corrcoef(d1,d2);ccf(i)=ccfM(2);
  %% CORR COEFFICINT OF RANK OF DATA
  %RccfM=corrcoef(sort(d1),sort(d2));Rccf(i)=RccfM(2);

  
  %MANUAL CORR COEF
  covar=sum((d1-mean(d1)).*(d2-mean(d2)))./length(d1);
  ccf(i)=covar./(std(d1)*std(d2));
    
  %rank transform
  Rcovar=sum((rd1-mean(rd1)).*(rd2-mean(rd2)))./length(d1);
  Rccf(i)=Rcovar./(std(rd1)*std(rd2));
  
  text(.5,.9,sprintf('ccf=%3.2f',ccf(i)),'units','normalized','FontSize',8);
  text(.5,.8,sprintf('Rccf=%3.2f',Rccf(i)),'units','normalized','FontSize',8);
  
end
end
suptitle('Goovaerts Fig 2.3')
%print -dpng GoovChap2_f2.3.png


figure
plot(ccf,Rccf,'k.',[0 1],[0 1],'r-')
xlabel('Correlation Coefficient')
ylabel('Rank Transformed Correlation Coefficient')
title('Goovaerts Fig 2.4')
%print -dpng GoovChap2_f2.4.png

%% CROSS SEMIVAR FUNCTION CONTINOUS
figure
i=0;
for i1=1:(ncon-1)
for i2=(i1+1):(ncon)
  i=i+1;
  subplot(ceil(nsc/ncol),ncol,i);
  [hc,g]=csemivar_exp([x y],p(:,icon(i1)),p(:,icon(i2)),[0:.1483:2.22485],1);
  plot(hc,g)
  title(sprintf('%s-%s',pHeader{icon(i1)},pHeader{icon(i2)}));
  ax=axis;
  ax(1)=0;
  ax(2)=max(hc);axis(ax)
  xlabel('offset [km]')
  ylabel('Cross Semivariogram [km]')
end
end
print -dpng GoovaertsChap2ExpCoVar.png


%% CROSS SEMIVAR FUNCTION DISCRETE
figure
i=0;
for i1=1:(ndis-1)
for i2=(i1+1):(ndis)
  i=i+1;
  %subplot(ceil(nsc/ncol),ncol,i);
  [hc,g]=csemivar_exp([x y],p(:,idis(i1)),p(:,idis(i2)),[0:.1483:2.22485],1);
  plot(hc,g)
  title(sprintf('%s-%s',pHeader{idis(i1)},pHeader{idis(i2)}));
  xlabel('offset [km]')
  ylabel('Cross Semivariogram [km]')
  ax=axis;
  ax(1)=0;
  ax(2)=max(hc);axis(ax)
end
end
print -dpng GoovaertsChap2ExpDisVar.png


