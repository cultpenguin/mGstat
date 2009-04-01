echo on;

% Example 1 : 1D - NO DATA UNCERTAINTY
try
    d=read_eas([mgstat_dir,filesep,'examples',filesep,'data',filesep,'transect.dat']);
    ii=find(d(:,4)~=-99);
    pos_known=d(ii,1);
    val_known=d(ii,4);
    dx=(d(2,1)-d(1,1))/8;
    pos_est=[min(d(:,1)):dx:max(d(:,1))];
    pos_est=pos_est(:);
    %pos_est=d(:,1);
    
catch
    pos_known=[1;5;10];
    val_known=[0 3 2]'; % adding some uncertainty
    pos_est=[0:.01:10]';
end

V='1.4 Exp(.1)';
[d_est,d_var]=krig_npoint(pos_known,val_known,pos_est,V);
figure(1);
plot(pos_est,d_est,'r-',pos_est,d_var,'b-',pos_known,val_known(:,1),'g*')
ax=axis;
legend('OK estimate','OK variance','Observed Data')
title(['V = ',V])

%disp('Hit key to continue');pause;

V='0.6 Nug(0) + 0.8 Exp(.2)';
[d_est,d_var]=krig_npoint(pos_known,val_known,pos_est,V);
figure(2);
plot(pos_est,d_est,'r-',pos_est,d_var,'b-',pos_known,val_known(:,1),'g*')
axis(ax);
legend('OK estimate','OK variance','Observed Data')
title(['V = ',V])

disp('GSTAT compare to mGstat : Hit key to continue');pause;

figure(3);
[d_est_gstat,d_var_gstat]=gstat_krig(pos_known,val_known,pos_est,V);
plot(pos_est,d_est,'r-',pos_est,d_est_gstat,'r.',pos_est,d_var,'b-',pos_est,d_var_gstat,'b.',pos_known,val_known(:,1),'go')
axis(ax);
legend('OK est (mgstat)','OK est (gstat)','OK var (mgstat)','OK var (gstat)','Observed Data')
title(['V = ',V])

disp('Next: 2DHit key to continue');pause;
try
    [p,hp]=read_eas([mgstat_dir,filesep,'examples',filesep,'data',filesep,'prediction.dat']);
    [v,hv]=read_eas([mgstat_dir,filesep,'examples',filesep,'data',filesep,'validation.dat']);
    idata_col=5;
    idata_name=hp{idata_col};
    pos_known=p(:,1:2);
    val_known=p(:,idata_col);
    nx=30;
    ny=35;
    dx=(max(d(:,1))-min(d(:,1)))./nx;
    dy=(max(d(:,2))-min(d(:,2)))./ny;
    x=[min(d(:,1)):dx:max(d(:,1))];;
    y=[min(d(:,2)):dy:max(d(:,2))];;
    [xx,yy]=meshgrid(x,y);
    pos_est=[xx(:) yy(:)];
        
catch
    pos_known=[0 1;5 1;10 1];
    val_known=[0 3 2]';
    pos_est=[1.1 1];
end

V='0.1 Nug(0) + 0.7 Exp(2)';
options.null='';
[d_est,d_var]=krig(pos_known,val_known,pos_est,V,options);
[d_est_gstat,d_var_gstat]=gstat_krig(pos_known,val_known,pos_est,V,options);
figure(4);subplot(1,2,1);
scatter(pos_est(:,1),pos_est(:,2),10,d_est,'filled');
hold on
% KNOWN
plot(pos_known(:,1),pos_known(:,2),'w.','MarkerSize',22),
scatter(pos_known(:,1),pos_known(:,2),12,val_known,'filled');
% VALIDATION
%plot(v(:,1),v(:,2),'k.','MarkerSize',22),
scatter(v(:,1),v(:,2),12,v(:,idata_col),'filled');
hold off
axis image
title(['OK estimate ',idata_name])
colorbar;

figure(4);subplot(1,2,2);
scatter(pos_est(:,1),pos_est(:,2),10,d_var,'filled');
axis image
title(['OK variance ',idata_name])
colorbar;

return


%
% Example 2 : 1D - Data Uncertainty 
% pos_known=[1;5;10];
% val_known=[0 3 2;0 1 0]'; % adding some uncertainty
% pos_est=[0:.01:10]';
% V=deformat_variogram('1 Sph(2)');
% for i=1:length(pos_est);
%   [d_est(i),d_var(i)]=krig(pos_known,val_known,pos_est(i),V);
% end
% plot(pos_est,d_est,'r.',pos_est,d_var,'b.',pos_known,val_known(:,1),'g*')
% legend('OK estimate','OK variance','Observed Data')
% title(['using data uncertainty, V = ',V])
%
%
% Example 3 : 2D : 
% pos_known=[0 1;5 1;10 1];
% val_known=[0 3 2]';
% pos_est=[1.1 1];
% V='1 Sph(2)';
% [d_est,d_var]=krig(pos_known,val_known,pos_est,V,options);
%

echo off