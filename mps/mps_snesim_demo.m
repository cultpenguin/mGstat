rng(1);
clear all;close all
options.n_cond=25;
options.n_template=25;

%options.n_cond=19;
%options.n_template=19;

options.n_cond=9;
options.n_template=9;

%options.n_mulgrids=4;
options.n_mulgrids=4;

options.plot=1;options.plot_interval=100;

options.rand_path=1;

SIM=ones(30,30).*NaN;
TI=channels;TI=TI(4:4:end,4:4:end);
%TI=channels;%TI=TI(2:2:end,2:2:end);

[out,o]=mps_snesim(TI,SIM,options);
return

figure(5);
subplot(2,3,1);imagesc(out);axis image
subplot(2,3,2);imagesc(o.C);colorbar;axis image
subplot(2,3,3);imagesc(o.IPATH);colorbar;axis image
options.n_max_ite=10000;
[out_dsim,o_dsim]=mps_dsim(TI,SIM,options);
subplot(2,3,4);imagesc(out_dsim);colorbar;axis image


return
%%
[out1,o1]=mps_snesim(TI,SIM,o);

%%
n=prod(size(SIM));
n_resim=ceil(0.05*n);
for i=1:50;
  SIM2=out1;
  
  i_resim=randomsample(1:n,n_resim);
  SIM2(i_resim)=NaN;
  [out1,o1]=mps_snesim(TI,SIM2,o1);
  figure(9)
  imagesc(out1);axis image;drawnow;
end
  



