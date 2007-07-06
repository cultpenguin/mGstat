% LOAD DATA
[data,header]=read_eas('prediction.dat');
x_obs=data(:,1);
y_obs=data(:,2);
iuse=5;
d_obs=data(:,iuse);
n=length(d_obs);

ii=1:1:n;
%ii=[1 20];
%ii=[10:10:n]
x_obs=x_obs(ii);
y_obs=y_obs(ii);
d_obs=d_obs(ii);

ax=[min(x_obs) max(x_obs) min(y_obs) max(y_obs)];
cax2=[min(d_obs) max(d_obs)];
cax=[0 2.4];
hr=linspace(min(d_obs),max(d_obs),15);


% FIRST MODEL THE NORMAL SCORE
w1=2; dmin=0; % interpolation options for lower tail
w2=.5; dmax=max(d_obs).*1.03;% interpolation options for upper tail
                           % See Goovaerts page 280 for more.
figure;
[d_nscore,o_nscore]=nscore(d_obs,w1,w2,dmin,dmax);

% write data to gstat
write_eas('NscoreCd.eas',[x_obs,y_obs,d_nscore(:)]);


% MODEL THE VARIOGRAM

%read parameter file
parfile='gstat_estsim.cmd';
%parfile='gstat_estsim_alt.cmd';
G=read_gstat_par(parfile);

nmodels=length(G.data);

G.mask{1}.file='JuraMask_0_05.asc';


% GET VARIOGRAM MODEL
V=G.variogram{1}.V;
varr=[0:.1:2];
[sv]=semivar_synth(V,varr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% CONVENTONAL ESTIMATION
% CALL mgstat
if isfield(G,'method'), G=rmfield(G,'method'); end
if isfield(G,'set'), G=rmfield(G,'set'); end
[p_est,v_est]=mgstat(G);

% read the mask
[mask,x,y]=read_arcinfo_ascii(G.mask{1}.file);

% FIND DATA TO ACTUALLY PLOT
nn=find(v_est{1}>0.95);
nanmask=1-mask;
nanmask(nn)=NaN;


% NOW SIMULATION
% CALL mgstat
G.method{1}.gs=''
G.set.nsim=40;
[p_sim,v_sim]=mgstat(G);


%%%%%%
%% COMPARE EST and SIM
figure

%%% FIRST OBSERVED DATA
subplot(3,3,1);
scatter(x_obs,y_obs,20,d_obs,'filled');
axis(ax);axis image;caxis(cax)
colorbar
ylabel('ORIG DATA')

subplot(3,3,3)
hist(d_obs,hr);
set(gca,'Xlim',[cax2])

%%
% ESTIMATION
subplot(3,3,4);
imagesc(x,y,nanmask.*inscore(p_est{1},o_nscore));
axis(ax);axis image;caxis(cax)
set(gca,'Ydir','normal')
colorbar
ylabel('SK ESTIMATION')

subplot(3,3,6)
% data within mask 
imask=find(nanmask==1);
hist(inscore(p_est{1}(imask),o_nscore),hr);
set(gca,'Xlim',[cax2])


%%
% SIMULAION
subplot(3,3,7);
imagesc(x,y,nanmask.*inscore(p_sim{1},o_nscore));
axis(ax);axis image;caxis(cax)
set(gca,'Ydir','normal')
colorbar
ylabel('SK SIMULATION')

subplot(3,3,9)
hist(inscore(p_sim{1}(:),o_nscore),hr);
set(gca,'Xlim',[cax2])


% VARIOGRAMS
% OBS DATA
[varr2,hc(1,:)]=semivar_exp([x_obs y_obs],d_obs,varr);
[xx,yy]=meshgrid(x,y);
dimask=max(1,round(length(imask)/700));
imask2=imask(dimask:dimask:length(imask));
%[varr2,hc(2,:)]=semivar_exp([xx(imask2) yy(imask2)],inscore(p_est{1}(imask2),o_nscore),varr);
[varr2,hc(2,:)]=semivar_exp([xx(imask2) yy(imask2)],(p_est{1}(imask2)),varr);
%[varr2,hc(3,:)]=semivar_exp([xx(imask2) yy(imask2)],inscore(p_sim{1}(imask2),o_nscore),varr);
[varr2,hc(3,:)]=semivar_exp([xx(imask2) yy(imask2)],(p_sim{1}(imask2)),varr);



for i=1:3,
  subplot(3,3,2+(i-1)*3)
  plot(varr,sv,'k-')
  hold on
  plot(varr2,hc(i,:),'r*');
  hold off
end
print -dpng EstSim_Stats.png
  

%%%
% SIMS
nsim=G.set.nsim;
nsp=ceil(sqrt(nsim));
figure
for i=1:nsim
  subplot(nsp,nsp,i)
  imagesc(x,y,inscore(p_sim{i},o_nscore))
  axis(ax);axis image;caxis(cax)
  set(gca,'Ydir','normal','FontSize',4)
end
print -dpng EstSim_Sims.png
  
  



%%%
% ETYPE
for i=1:G.set.nsim
  pm_sim(i,:,:)=p_sim{i};
  pmi_sim(i,:,:)=inscore(p_sim{i},o_nscore);
end
etype=squeeze(mean(pm_sim));
etypei=squeeze(mean(pmi_sim));
figure
subplot(2,2,1);
  imagesc(x,y,p_est{1});
  axis(ax);axis image;caxis([-3 3])
  set(gca,'Ydir','normal' )
  title('NORMAL SCORE ESTIMATION')
subplot(2,2,2);
  imagesc(x,y,etype);
  axis(ax);axis image;caxis([-3 3])
  set(gca,'Ydir','normal' )
  title('NORMAL SCORE SIMULATION ETYPE')

subplot(2,2,3);
  imagesc(x,y,inscore(p_est{1},o_nscore));
  axis(ax);axis image;caxis(cax)
  set(gca,'Ydir','normal' )
  title('BACKTRANSFORMED ESTIMATION')
subplot(2,2,4);
  imagesc(x,y,etypei);
  axis(ax);axis image;caxis(cax)
  set(gca,'Ydir','normal' )
  title('BACKTRANSFORMED SIMULATION ETYPE')
suptitle(sprintf('Comparison of Estimation and Etype for isim=%d',nsim))

print -dpng EstSim_EtypeEstim.png
  

% A MOVIE
figure
for i=1:nsim
  imagesc(x,y,inscore(p_sim{i},o_nscore))
  axis(ax);axis image;caxis(cax)
  set(gca,'Ydir','normal','FontSize',9)
  title(['ISIM=',num2str(i)])
  drawnow;
  pause(.1)
end


