nx=25;nz=50;dx=.25;dz=.25;
%nx=50;nz=100;dx=.125;dz=.125;
nx=100;nz=200;dx=.125/2;dz=.125/2;
%nx=200;nz=400;dx=.125/4;dz=.125/4;


x=[1:1:nx]*dx;
z=[1:1:nz]*dz;

xs=4;zs=3;
vsx=5;
hsz=10;
tmax=110;

fmax=0.1;
dt=0.2;
v=ones(nz,nx).*0.13;
%su_write_model(v,'vel.out')
zs_array=1:1:12;
for izs=1:length(zs_array)
    [vs(:,:,izs),hs(:,:,izs),ss]=sufdmod2_easy(x,z,v,xs,zs_array(izs),vsx,hsz,tmax);
    %    [vs(:,:,izs),hs(:,:,izs),ss]=sufdmod2_easy(x,z,v,xs,zs_array(izs),vsx,hsz,tmax,fmax,dt);

    [d,STH,SH]=ReadSu('hseis.out','endian','b');
    t=STH(1).DelayRecordingTime+[0:1:(STH(1).ns-1)]*STH(1).dt./1e-6;
    nt=length(t);
    subplot(2,2,1);imagesc(z,t,vs(:,:,izs)')
    subplot(2,2,2);imagesc(x,t,hs(:,:,izs)')
    
    subplot(2,1,2)
    for it=1:nz;
        i=find(abs(vs(:,it,izs))>0.01);
        t1(it)=t(i(1));
        plot(t,vs(:,it,izs),'k-',t1(it),vs(i(1),it,izs),'r*');
        title(sprintf('t=%6.3f',t(it)))
        set(gca,'ylim',[-1 1])
        drawnow;
    end
    t_obs(:,izs)=t1;
    
    
end
