% mps_test

clear all;close all;
nsim=32;

options.type='snesim';
%options.type='dsim';
%options.type='enesim';

options.rand_path=1;
options.n_cond=5;
options.n_max_ite=30000;
options.plot=0;

% optional snesim options
options.n_mulgrids=4;

SIM=ones(15,15).*NaN;
TI=load('cb_4.asc');
TI=channels;TI=TI(10:10:end,10:10:end);

doUncond=0;
doCond=0;
doSoft=1;

%% UNCONDITIONAL REALIZATIONS

if doUncond==1;
  Mout=zeros(size(SIM,1),size(SIM,2),nsim);
  rng(2)
  for i=1:nsim
    progress_txt(i,nsim)
    [out,options]=mps(TI,SIM,options);
    o{i}=options;
    Mout(:,:,i)=out;
    
    figure(1);
    [em,ev]=etype(Mout);
    subplot(1,3,1);
    imagesc(out);axis image;caxis([0 1])
    subplot(1,3,2);
    imagesc(em);axis image;colorbar;caxis([0 1])
    subplot(1,3,3);imagesc(ev);axis image;caxis([0 var(TI(:))]);colorbar
    colormap(cmap_linear)
    drawnow;
  end
  
  %%
  figure(1);clf;
  for i=1:min([9, nsim])
    subplot(3,3,i);
    imagesc(Mout(:,:,i));axis image;
  end
  suptitle(sprintf('unconditional %s',options.type))
  
  figure(2);clf;
  [em,ev]=etype(Mout);
  subplot(1,2,1);
  imagesc(em);axis image;
  colorbar
  caxis([0 1])
  subplot(1,2,2);
  imagesc(ev);axis image;
  caxis([0 max(ev(:))])
  colorbar
  suptitle(sprintf('Etype unconditional %s',options.type))
end

%% CONDITIONAL SIMULATION
if doCond==1;
  SIM=NaN.*SIM;SIM(1,1:2)=0;
  Mout=zeros(size(SIM,1),size(SIM,2),nsim);
  rng(2)
  for i=1:nsim
    progress_txt(i,nsim)
    [out,options]=mps(TI,SIM,options);
    o{i}=options;
    Mout(:,:,i)=out;
    
    figure(1);
    [em,ev]=etype(Mout);
    subplot(1,3,1);
    imagesc(out);axis image;caxis([0 1])
    subplot(1,3,2);
    imagesc(em);axis image;colorbar;caxis([0 1])
    subplot(1,3,3);imagesc(ev);axis image;caxis([0 var(TI(:))]);colorbar
    colormap(cmap_linear)
    drawnow;
  end
  
end

%% USING LOCAL A PRIORI PROBABILITY
if doSoft==1;
  LOCALPROB{1}=SIM;
  LOCALPROB{1}(:)=0.5;
  LOCALPROB{1}(1:5,:)=0.9;
  LOCALPROB{2}=1-LOCALPROB{1};
  
  options.local_prob=LOCALPROB;
  profile on
  [out,options]=mps(TI,SIM,options);
  profile report
  return
  rng(2)
  for i=1:nsim
    progress_txt(i,nsim)
    [out,options]=mps(TI,SIM,options);
    o{i}=options;
    Mout(:,:,i)=out;
    
    figure(1);
    [em,ev]=etype(Mout);
    subplot(1,3,1);
    imagesc(out);axis image;caxis([0 1])
    subplot(1,3,2);
    imagesc(em);axis image;colorbar;caxis([0 1])
    subplot(1,3,3);imagesc(ev);axis image;caxis([0 var(TI(:))]);colorbar
    colormap(cmap_linear)
    drawnow;
  end
  
end
