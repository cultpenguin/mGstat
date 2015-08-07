clear all;close all

ti=channels;
S=snesim_init(ti(2:2:end,2:2:end));
x=1:50;
y=1:50;

S.rseed=1;

%% unconditional realization
S=snesim(S,x,y);

imagesc(S.x,S.y,S.D);axis image;


%% Conditional realization
Sc=S;
Sc.n_mulgrids=1;
Sc.nsim=10;

xc=1:1:length(x);
yc=0.*xc + 20;
zc=0.*xc + S.dim.zmn; 
vc=0.*xc + 1; % black
fname='cond.dat';
write_eas(fname,[xc(:) yc(:) zc(:) vc(:)])

Sc.fconddata.fname=fname;
Sc.fconddata.xcol=1;
Sc.fconddata.ycol=2;
Sc.fconddata.zcol=3;
Sc.fconddata.vcol=4;
Sc=snesim(Sc);

figure(2);
subplot(1,2,1);imagesc(Sc.x,Sc.y,Sc.etype.mean);
caxis([0 1]);axis image;
subplot(1,2,2);imagesc(Sc.x,Sc.y,Sc.etype.var);
axis image;

%% Resimulation
Sr=S;
Sr.n_mulgrids=3;

Sr=snesim(Sr);
figure(3);
subplot(2,2,1),imagesc(Sr.x,Sr.y,Sr.D(:,:,1));;axis image;drawnow;

for i=1:10;
Sr.rseed=i;
Sr=snesim_set_resim_data(Sr,Sr.D,[6 6]);
Sr=snesim(Sr);

subplot(2,2,2)
d=read_eas(Sr.fconddata.fname);
plot(d(:,1),d(:,2),'r.')
axis([min(x) max(x) min(y) max(y)])

subplot(2,2,3)
imagesc(Sr.x,Sr.y,Sr.D(:,:,1));;axis image;drawnow;

subplot(2,2,4)
imagesc(Sr.x,Sr.y,S.D(:,:,1)-Sr.D(:,:,1));;axis image;drawnow;
caxis([-1 1])

end



