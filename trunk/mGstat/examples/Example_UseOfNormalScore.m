% Example : Example_UseOfNormalScore
%
% Example of using normal score transformation in Matlab, while
% using GSTAT for kriging.
%
%

% Load data
doLoadData=1;
if doLoadData==1
  
  [data,header]=read_eas('prediction.dat');
  
  
  x_obs=data(:,1);
  y_obs=data(:,2);
  iuse=6;
  d_obs=data(:,iuse);
  
  n=length(x_obs);
  
  figure;
  % PRIOR CPDF
  plot(sort(d_obs),[1:1:n]./n);
  xlabel(header{iuse})
  ylabel('Prob(Z<z)')
  
  % normalscore transform
  w1=1; dmin=-.1; % interpolation options for lower tail 
  w2=1; dmax=max(d_obs).*1.2;% interpolation options for upper tail 
                % See Goovaerts page 280 for more.
  figure;
  [d_nscore,o_nscore]=nscore(d_obs,w1,w2,dmin,dmax);
  
  % PLOT NORMAL SCORES
  figure
  subplot(1,2,1)
  hist(d_nscore);
  title([header{iuse},' Normal Score data'])

  subplot(1,2,2);
  plot(x_obs,y_obs,'k.','markerSize',41);
  hold on
  scatter(x_obs,y_obs,40,d_nscore,'filled');
  hold off
  title([header{iuse},' Normal Score data'])
  axis image
  colorbar
  
  % write data to gstat
  write_eas('Nscore.eas',[x_obs,y_obs,d_nscore(:)]);
  
  save TestNscore
else 
  load TestNscore
end


%% WRITE MASK TO FILE
dx=.02;
xx=[min(x_obs):dx:max(x_obs)];
yy=[min(y_obs):dx:max(y_obs)];
xx=[0:dx:ceil(max(x_obs))];
yy=[0:dx:ceil(max(y_obs))];
nx=length(xx);
ny=length(yy);
nanvalue=[];
write_arcinfo_ascii('2dmask.asc',zeros(ny,nx),xx,yy,nanvalue);
[xx1,xx2]=read_arcinfo_ascii('2dmask.asc');


%%%
%%%
%%% CALL GSTAT
!gstat Example_UseOfNormalScore.cmd
%%%
%%%
%%%
!gstat -e convert -f a Nscore_pred Nscore_pred.asc
!gstat -e convert -f a Nscore_var Nscore_var.asc

[pred,x,y]=read_arcinfo_ascii('Nscore_pred.asc');
[var,x,y]=read_arcinfo_ascii('Nscore_var.asc');


figure;
subplot(2,1,1);
imagesc(x,y,pred);
hold on
plot(x_obs,y_obs,'k.','markerSize',41);
scatter(x_obs,y_obs,40,d_nscore);
hold off
axis image
set(gca,'ydir','normal')
colorbar

subplot(2,1,2);
imagesc(x,y,var);
set(gca,'ydir','normal')
colorbar
axis image


% INVERS NORMAL SCORE TRANSFORM
d_out=inscore(pred,o_nscore);
var_out=inscore(var,o_nscore);
figure;
imagesc(x,y,d_out);
hold on
%plot(x_obs,y_obs,'k.','markerSize',41);
scatter(x_obs,y_obs,40,d_obs);
hold off
set(gca,'ydir','normal')
colorbar
axis image

figure;
% 95% conf int.
subplot(2,1,1)
d_out_95m=inscore(pred-2*sqrt(var),o_nscore);
imagesc(x,y,d_out_95m);
set(gca,'ydir','normal')
cax=caxis;
axis image
colorbar

subplot(2,1,2)
d_out_95p=inscore(pred+2*sqrt(var),o_nscore);
imagesc(x,y,d_out_95p);
set(gca,'ydir','normal')
axis image
caxis(cax)
colorbar
suptitle('95%% confidence intervals')

figure;
surf(x,y,d_out_95m);
hold on;
surf(x,y,d_out);
surf(x,y,d_out_95p);
hold off
shading interp
title([header{iuse},' Backtransformed estimates - pred +- 2\sigma'])
view([-68 83])

figure;
surf(x,y,var_out,d_out)
xlabel('X')
ylabel('Y')
zlabel('variance')
title([header{iuse},' colorbar indicates prediction, elevation indicates uncertainty'])
