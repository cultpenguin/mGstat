clear all;close all

S=snesim_init;
x=1:250;
y=1:200;

S.rseed=1;

%% unconditional realization
try;delete(S.fconddata.fname);end
S=snesim(S,x,y);

figure(1);
imagesc(S.x,S.y,S.D);axis image;

%% unconditional, constant rotation
figure(2);
i=0;
for rot=[0 30 60 90];
  i=i+1;
  S=snesim_set_rotation_affinity(S,rot);
  S=snesim(S,x,y);
  figure(2);subplot(4,1,i);imagesc(S.D);axis image
  title(sprintf('rotation = %d def',rot))
end

%% unconditional, varying rotation
rot=zeros(size(S.D));
for ix=1:(S.nx/2);rot(:,ix)=90.*cos(2*pi*ix/S.nx);end
for iy=1:S.ny;rot(iy,:)=rot(iy,:).*(iy./S.ny);end
S=snesim_set_rotation_affinity(S,rot,1);  
S=snesim(S,x,y);
figure(3);
subplot(2,1,1);imagesc(rot);axis image;colorbar
subplot(2,1,2);imagesc(S.D);axis image

%% unconditional, varying rotation, and scaling
S=snesim_set_rotation_affinity(S,rot,2);  
S=snesim(S,x,y);
figure(4);
subplot(2,1,1);imagesc(rot);axis image;colorbar
subplot(2,1,2);imagesc(S.D);axis image


return

%% Conditional realization
S=snesim_init;
S=snesim(S);
Sc=S;
Sc.nmulgrids=1;
Sc.nsim=20;

xc=1:6:length(x);
yc=0.*xc + 20;
zc=0.*xc + S.zmn;
vc=0.*xc + 1; % black
fname='cond_hor_line.dat';
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
return
%% Resimulation
Sr=S;
Sr.nmulgrids=3;

Sr=snesim(Sr);
m1=Sr.D;
figure(3);
subplot(2,2,1),imagesc(Sr.x,Sr.y,Sr.D(:,:,1));;axis image;drawnow;

for i=1:10;
    Sr.rseed=i;
    Sr=snesim_set_resim_data(Sr,Sr.D,[10 10]);
    
    Sr=snesim(Sr);
    
    subplot(2,2,2)
    try
        d=read_eas(Sr.fconddata.fname);
    catch
        d=[];
    end
    plot(d(:,1),d(:,2),'r.')
    set(gca,'ydir','reverse')
    axis([min(x) max(x) min(y) max(y)])
    
    subplot(2,2,3)
    imagesc(Sr.x,Sr.y,Sr.D(:,:,1));;axis image;drawnow;
    
    subplot(2,2,4)
    imagesc(Sr.x,Sr.y,Sr.D(:,:,1)-m1);;axis image;drawnow;
    caxis([-1 1])
    
end



