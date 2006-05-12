% grad_deform_prior : sampling the pdf using gradual deformation
%
%
G=read_gstat_par('grad_deform.cmd');
d_curr=gstat(G);
d_curr=d_curr{1};

sk_mean=G.data{1}.sk_mean;

[mask,x,y,dx]=read_arcinfo_ascii(G.mask{1}.file);

[xx,yy]=meshgrid(x,y);

doPlot=0;

cax=[.1 .16];

nit=1000;

for i=1:nit
  
  progress_txt(i,nit,'Gradually deforming')
  
  gstep=pi/4;
  
  d_new=gstat(G);
  d_curr=grad_deform(d_curr-sk_mean,d_new{1}-sk_mean,gstep)+sk_mean;
  %d_curr=d_new{1};
  
  m(i)=mean(d_curr(:));
  v(i)=var(d_curr(:));
  %[gamma,hc,np,av_dist]=semivar_exp_gstat([xx(:) yy(:)],d_curr(:),90-6.5,40,20);
  [gamma(:,i),hc,np,av_dist]=semivar_exp_gstat([xx(:) yy(:)],d_curr(:),0,180,.5,20);
  if doPlot==1
    figure(1);
    imagesc(d_curr');axis image
    caxis(cax)
    title(num2str(i));
    drawnow;
    pause(1);
  end
end
  

figure(2)
subplot(4,1,1);plot(m);ylabel('Mean')
subplot(4,1,2);plot(v);ylabel('Variance')
subplot(4,2,5);hist(m);xlabel('Mean')
hold on
ax=axis; plot([sk_mean sk_mean],[0 ax(4)],'r-')
hold off
subplot(4,2,6);hist(v);xlabel('Variance')
hold on
gvar=sum([G.variogram{1}.V.par1]);
ax=axis; plot([1 1].*gvar,[0 ax(4)],'r-')
hold off
subplot(4,1,4);

g_synth=semivar_synth(G.variogram{1}.V,hc,1);
plot(hc,gamma,'k-')
hold on
plot(hc,g_synth,'r-')
hold off
xlabel('Distance');
ylabel('\gamma')

