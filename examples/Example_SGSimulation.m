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


% FIRST MODEL THE NORMAL SCORE
w1=2; dmin=-.1; % interpolation options for lower tail
w2=.5; dmax=max(d_obs).*1.2;% interpolation options for upper tail
                           % See Goovaerts page 280 for more.
figure;
[d_nscore,o_nscore]=nscore(d_obs,w1,w2,dmin,dmax);

% write data to gstat
write_eas('Nscore.eas',[x_obs,y_obs,d_nscore(:)]);

%read parameter file
G=read_gstat_par('gstat_sk_simulation.cmd');
%G=read_gstat_par('gstat_sk_aniso_simulation.cmd');

nmodels=length(G.data);

G.mask{1}.file='JuraMask_0_05.asc';

% CALL mgstat
if isfield(G,'method'), G=rmfield(G,'method'); end
if isfield(G,'set'), G=rmfield(G,'set'); end
[p,v]=mgstat(G);

% read the mask
[mask,x,y]=read_arcinfo_ascii(G.mask{1}.file);


nn=find(v{2}>0.85);

figure;
for i=1:4
  subplot(2,4,i);
  d=p{i};d(nn)=NaN;
  imagesc(x,y,d);
  axis image
  set(gca,'Ydir','normal')
  title(format_variogram(G.variogram{i}.V,1))
  caxis([-3 3])
  
  subplot(2,4,i+4);
  imagesc(x,y,v{i});
  caxis([0 1])
  axis image
  set(gca,'Ydir','normal')
  
end
suptitle('ESTIMATION')
drawnow

print -dpng SGS_Estim.png

% NOW SIMULATION
% CALL mgstat
G.method{1}.gs=''
G.set.nsim=20;
[psim,vsim]=mgstat(G);
figure;
for i=1:3
  subplot(1,3,i);
  imagesc(x,y,psim{i});
  axis image
  set(gca,'Ydir','normal')
  caxis([-3 3])
  title(format_variogram(G.variogram{i}.V,1))
end
suptitle('SIMULATION')
drawnow
print -dpng SGS_Sims.png



%% PLOT SIMULATED DATA
nsim=G.set.nsim;

figure;
itype=3;
for i=1:nsim;
  imagesc(x,y,psim{itype,i}); 
  title(sprintf('%s,Normal Score Sim %d + %s',header{iuse},i,format_variogram(G.variogram{1}.V,1)))
  set(gca,'Ydir','normal');
  caxis([-3 3]);
  axis image;
  colorbar
  drawnow,
  M(i)=getframe;
  pause(.1);
end
movie2avi(M,'NscoreSim.avi')
 
figure;
nsp=ceil(sqrt(nsim));
for itype=1:nmodels
for i=1:nsim
  subplot(nsp,nsp,i)
  imagesc(x,y,psim{itype,i}); 
  set(gca,'Ydir','normal');  caxis([-3 3]);  axis image;  
end
suptitle(sprintf('%s - Normal Score Sim - %s',header{iuse},format_variogram(G.variogram{itype}.V,1)))
print -dpng SGS_SimNscore.png
eval(sprintf('print -dpng SGS_%d_SimNscore.png',itype));
end

%% MOVIE OF BACKTRANSFORMED DATA
figure;
for i=1:20;
  imagesc(x,y,inscore(psim{itype,i},o_nscore)); 
  title(sprintf('%s - Sim %d - %s',header{iuse},i,format_variogram(G.variogram{1}.V,1)))
  set(gca,'Ydir','normal');
  caxis([min(d_obs) max(d_obs)]);
  axis image;
  colorbar
  drawnow,
  M(i)=getframe;
  pause(.1);

end
movie2avi(M,'BacktransfomrSim.avi')

figure;
nsp=ceil(sqrt(nsim));
for itype=1:nmodels
clf
for i=1:nsim
  subplot(nsp,nsp,i)
  imagesc(x,y,inscore(psim{itype,i},o_nscore)); 
  caxis([min(d_obs) max(d_obs)]);
  set(gca,'Ydir','normal');  axis image;  
end
suptitle(sprintf('%s - Back Transformed Sim - %s',header{iuse},format_variogram(G.variogram{itype}.V,1)))
eval(sprintf('print -dpng SGS_%d_SimBackTransform.png',itype));
end
return


%%%%
%% variogram analysis
[xx,yy]=meshgrid(x,y);
nxy=length(x)*length(y);
 clear garr sv

ii=[3:3:nxy]';
for i=1:3
  [hc,garr(i,:)]=semivar_exp([xx(ii) yy(ii)],psim{i}(ii),[0:.05:1.5]);
  V=G.variogram{i}.V;
  [sv(i,:)]=semivar_synth(V,hc);
end
figure;
plot(hc,garr)
hold on
plot(hc,sv)
hold off
