% Example_UnconditionalSGS
%
%
G=read_gstat_par('gstat_uncond_simulation.cmd');

G.mask{1}.file='JuraMask_0_1.asc';
[mask,x,y]=read_arcinfo_ascii(G.mask{1}.file);

if exist('Va')==1
  G.variogram{1}.V=deformat_variogram(Va);
end

% CALL mgstat
[p,v]=mgstat(G);

% plot the simulated data
figure
imagesc(x,y,p{1})
set(gca,'Ydir','normal');
axis image;
caxis([-3 3])
colorbar
Va=format_variogram(G.variogram{1}.V);
suptitle(Va)
