S=read_snesim('snesim.par');
delete(S.fconddata.fname)  
delete('*.png');

S.nx=155;
S.ny=110;
S.nsim=1;


S=snesim(S);
[xx,yy]=meshgrid(S.x,S.y);
nit=200;

Dmul=zeros(S.ny,S.nx,nit);
for i=1:nit;

	% SELECT PART OF DATA FOR RE-SIMULATION
	d_lim=[25 18]
	%c_pert=[25 25];snesim_set_resim_data(S,S.D(:,:,1)',d_lim,c_pert);
        snesim_set_resim_data(S,S.D(:,:,1)',d_lim);
	

	% WRITE HARD DATA TO DISK

	% RUN SNESIM FOR RESIMULATION
	S.rseed=i;
	S=snesim(S);
	% VISULIZE
	figure(1);
	imagesc(S.x,S.y,S.D');
	Dmul(:,:,i)=S.D';
	axis image;
	drawnow;
	print('-dpng',space2char(sprintf('f%3d.png',i),'0'))

end	

[em,ev]=etype(Dmul);
figure(2);
subplot(2,1,1);imagesc(S.x,S.y,em);axis image;colorbar
subplot(2,1,2);imagesc(S.x,S.y,ev);colorbar;axis image
print('-dpng',space2char(sprintf('etype_n%3d.png',nit),'0'))


system(sprintf('convert f*.png -delay 100 mov_%d_%d_%d.gif',nit,S.nx,S.ny));


