% visim_condsim_alt
%
%
function Valt=visim_condsim_alt(V)

     
if isstruct(V)~=1
  V=read_visim(V);
end


%V.rseed=2;
%V.nsim=10;
%V.volnh.max=100;
%V.debuglevel=-10;
%V=visim(V);

tic

% GET GEOMETRY
[G,d_obs]=visim_to_G(V);

% ALTERNATE OUTPUT FILE
[f1,f2,f3]=fileparts(V.parfile);
filename=(sprintf('%s_alt%s',f2,f3));
Valt=V;
Valt.D=zeros(V.nx,V.ny,V.nsim);
Valt.parfile=filename;
write_visim(Valt);


nsim=V.nsim;
rseed=V.rseed;


% CONDITIONAL ESTIMATION
Vcond_est=V;
Vcond_est.rseed=rseed;
%Vcond_est.rseed=rseed+isim-1;
Vcond_est.nsim=0;
Vcond_est.densitypr=0;
Vcond_est.parfile='Cest.par';
Vcond_est.read_covtable=0; % DO NOT READ THE COV TABLE FROM DISK THIS TIME...
Vcond_est.read_lambda=0; % DO NOT READ LAMBDA FROM DISK (CALCULATE THEM)
Vcond_est=visim(Vcond_est);
v_cest=Vcond_est.etype.mean';

for isim=1:nsim
  progress_txt(isim,nsim,V.parfile);
  
  % UNCONDITIONAL SIMULATION
  Vuncond_sim=V;
  Vuncond_sim.rseed=rseed+isim-1;
  Vuncond_sim.cond_sim=0;
  Vuncond_sim.nsim=1;
  Vuncond_sim.parfile='Usim.par';
  Vuncond_sim=visim(Vuncond_sim);
  v_usim=Vuncond_sim.D';
  
  % CALCULATE ERRORS
  d_obs=Vuncond_sim.fvolsum.data(:,3);
  %v=v_cest';v=v(:);
  vfield=v_usim';v=vfield(:);
  d_est=G*v;
  
  % KRIG ERRORS
  % POINT DATA
  cdata=read_eas(V.fconddata.fname);
  cdata_err=cdata;
  [iix,iiy]=pos2index(cdata(:,1),cdata(:,2),V.x,V.y);
  for i=1:size(cdata,1);
    cdata_err(i,4)=vfield(iix(i),iiy(i));
  end
  write_eas('cond.eas',cdata_err);
  
  volsum=read_eas(V.fvolsum.fname);
  volsum(:,3)=d_est;
  %volsum(:,4)=volsum(:,4)./10000; % SET ACTUAL ERROR TO ZERO
  write_eas('err.eas',volsum);
  Vcond_est2=V;
  Vcond_est2.rseed=rseed;
%  Vcond_est2.rseed=rseed+isim-1;
  Vcond_est2.nsim=0;
  Vcond_est2.densitypr=0;
  Vcond_est2.fconddata.fname='cond.eas';
  Vcond_est2.fvolsum.fname='err.eas';
  Vcond_est2.parfile='Cest2.par';
  unix('cp lambda_Cest.out lambda_Cest2.out');
  unix('cp cd2v_Cest.out cd2v_Cest2.out');
  unix('cp cv2v_Cest.out cv2v_Cest2.out');
  Vcond_est2.read_covtable=1; % REUSE COVARIANCE LOOKUP TABLE
  Vcond_est2.read_lambda=1; % READ LAMBDA FROM DISK (DO not CALCULATE THEM)
  Vcond_est2=visim(Vcond_est2);
  v_cest_err=Vcond_est2.etype.mean';
  
  
  %% COMBINE 
  
  v_csim = v_cest + ( v_usim - v_cest_err ); 
  %
  v2=v_csim';v2=v2(:);
  d_est_csim=G*v2;
  
  Valt.D(:,:,isim)=v_csim';
  

  doPlot=0;
  
  if doPlot==1;
    subplot(2,3,4)
    plot(d_est,d_obs,'*');
    xlabel('uncond estimates');ylabel('observations')
    axis image
    
    subplot(2,3,5)
    plot(d_est_csim,d_obs,'*');
    xlabel('uncond estimates');ylabel('observations')
    axis image
    
    
    cax=[.11 .15];
    subplot(2,3,1);
    imagesc(V.x,V.y,v_cest);axis image;caxis(cax)
    subplot(2,3,2);
    imagesc(V.x,V.y,v_usim);axis image;caxis(cax)
    subplot(2,3,3);
    imagesc(V.x,V.y,v_cest_err);axis image;caxis(cax)
    subplot(2,3,6);
    imagesc(V.x,V.y,v_csim);axis image;caxis(cax)
    
    drawnow;
  end
  %
  
  
  disp(sprintf('            mean=%6.3f var=%10.8f',V.gmean,V.gvar))
  disp(sprintf('Uncon Sim : mean=%6.3f var=%10.8f',mean(v_usim(:)), var(v_usim(:))))
  disp(sprintf('Cond  Sim : mean=%6.3f var=%10.8f',mean(v_csim(:)), var(v_csim(:))))
%  disp(sprintf('Cond2 Sim : mean=%6.3f var=%10.8f',mean(v_csim_1(:)), var(v_csim_1(:))))
end


% SAVE ALT

[m,v]=etype(Valt.D);
Valt.etype.mean=m;
Valt.etype.var=v;

fout=sprintf('%s_alt.out',f2);
write_eas(fout,Valt.D(:));


Valt.time=toc;