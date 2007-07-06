% LOAD DATA
[data,header]=read_eas('prediction.dat');
x_obs=data(:,1);
y_obs=data(:,2);
iuse=5;
d_obs=data(:,iuse);
n=length(d_obs);

%read parameter file
G=read_gstat_par('gstat_ic_simulation.cmd');


% GET THRESHOLDS
nlevels=length(G.data);
for i=1:nlevels
  thr(i)=G.data{i}.I;
end

% read the mask
G.mask{1}.file='JuraMask_0_05.asc';
[mask,x,y]=read_arcinfo_ascii(G.mask{1}.file);


% PERFORM SIMULATION
% CALL mgstat
G.set.order=4; % PERFORM CUMULATIVE ORDER CORRECTIONS
G.set.nsim=4; % PERFORM CUMULATIVE ORDER CORRECTIONS
G.method{1}.is='';
[p,v]=mgstat(G);


nx=length(x);
ny=length(y);

nsim=G.set.nsim;


% GET INDICATOR MAP FROM SIMULATION
for isim=1:nsim
  for ix=1:nx; 
  for iy=1:ny; 
    for i=1:nlevels, 
      c(i)=p{i,isim}(iy,ix);
    end; 
    vest(iy,ix,isim)=min(find(c==1))  ;
  end;
  end
end

applevels=[thr(1),(thr(1:(nlevels-1))+thr(2:nlevels))./2];
vest_trans=vest;
for i=1:nlevels
  vest_trans(find(vest==i))=applevels(i);
end

figure
nsp=ceil(sqrt(nsim));
for i=1:nsim
  subplot(nsp,nsp,i)
  imagesc(x,y,vest(:,:,i))
  axis image;set(gca,'ydir','normal')
  caxis([0 nlevels])
  colorbar
end
suptitle('INDICATOR SIMULATION - LEVELS')
print -dpng SIS_Levels.png
figure
nsp=ceil(sqrt(nsim));
for i=1:nsim
  subplot(nsp,nsp,i)
  imagesc(x,y,vest_trans(:,:,i))
  axis image;set(gca,'ydir','normal')
  caxis([0 2.4])
  colorbar
end
suptitle('INDICATOR KRIGING - VALUES')
print -dpng SIS_Values.png