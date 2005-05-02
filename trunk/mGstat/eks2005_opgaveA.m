% eks2005_opgavea
parfile='eksamen2005_a.cmd';
p=mgstat(parfile);
G=read_gstat_par(parfile);

[pred,x,y]=read_arcinfo_ascii(G.predictions{1}.file);

% randomly select np points
np=500;
nx=length(x);
ny=length(y);
rand('seed',2);
ix=round(rand(1,np)*(nx-1))+1;
iy=round(rand(1,np)*(ny-1))+1;

for i=1:np
	xobs(i)=x(ix(i));
	yobs(i)=y(iy(i));
	vobs(i)=pred(iy(i),ix(i));
end

h{1}='X';
h{2}='Y';
h{3}='VALUE';
write_eas('opg1_obs.eas',[xobs' yobs' vobs'],h,'Opgave 1 Eksamen 2005')

subplot(2,2,1)
imagesc(x,y,pred);
hold on
plot(x(ix),y(iy),'*')
hold off
cax=caxis;
ax=axis;
axis image
set(gca,'ydir','normal');

subplot(2,2,2)
scatter(xobs,yobs,20,vobs,'filled')
axis(ax);caxis(cax)
axis image

[hc,garr,h,gamma,hangc]=semivar_exp([xobs' yobs'],vobs',30,4);
subplot(2,2,3)
plot(hc,garr)
legend(num2str(180-[180.*hangc./pi]'))
  
hold on
plot(hc,semivar_synth('1 Exp(.3)',hc,1),'k-')
plot(hc,semivar_synth('1 Exp(.4)',hc,1),'k-')
plot(hc,semivar_synth('1 Exp(.5)',hc,1),'k-')
plot(hc,semivar_synth('1 Exp(.6)',hc,1),'k-')
plot(hc,semivar_synth('1 Exp(.7)',hc,1),'k-')
plot(hc,semivar_synth('1 Exp(.8)',hc,1),'k-')
plot(hc,semivar_synth('1 Exp(.9)',hc,1),'k-')
plot(hc,semivar_synth('1 Exp(1.0)',hc,1),'k-')
hold off
