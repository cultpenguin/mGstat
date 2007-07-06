% GENERATE A REFERENCE DATA SET USING UNCONDITIONAL GAUSSIAN SIMULATION
x=[0:.05:10];
y=[0:.05:10];
V=visim_init(x,y);
V.rseed=1;
V.Va.a_hmax=4; % maximum correlation length
V.Va.a_hmin=.5;  % minumum correlation length
V.Va.ang1=90-22.5;   % Rotation angle of dip(clockwise from north)
V.Va.it=1;     % Gaussian semivariogram
V=visim(V);    % run visim;

[x_obs,y_obs]=meshgrid(x,y);
d_obs=V.D(:,:,1);
n_obs=prod(size(d_obs));


% CHOOSE SOME DATA FOR SEMIVARIOGRAM ANALYSIS
n_use=1000;
i_use=round(rand(1,n_use)*(n_obs-1))+1;
i_use=unique(i_use);

x_use=x_obs(i_use);
y_use=y_obs(i_use);
d_use=d_obs(i_use);

% PLOT DATA
figure(1);
imagesc(V.x,V.y,V.D(:,:,1));
title(visim_format_variogram(V))
axis image;
hold on
plot(x_use,y_use,'w.','MarkerSize',22)
scatter(x_use,y_use,20,d_use,'filled')
hold off
drawnow;

% SEMIVARIOGRAM ANALYSIS ISOTROPIC
[gamma_iso,hc,np,av_dist]=semivar_exp_gstat([x_use(:) y_use(:)],[d_use(:)]);
figure(2);
plot(hc,gamma_iso);
title('isotropic');xlabel('Distance');ylabel('\gamma')

% SEMIVARIOGRAM ANALYSIS ANISOTROPIC
ang_array=[0,22.5,45,67.5,90];
ang_tolerance=10;
for i_ang=1:length(ang_array);   
    [gamma_an(:,i_ang),hc,np,av_dist]=semivar_exp_gstat([x_use(:) y_use(:)],[d_use(:)],ang_array(i_ang),ang_tolerance);
end
figure(3);
plot(hc,gamma_an);xlabel('Distance');ylabel('\gamma')
title('ANisotropic'); 
legend(num2str(ang_array'))
 
% SYNTHETICAL SEMIVARIOGRAM
gamma_synth=semivar_synth('0.0001 Nug(0) + 1 Sph(1)',hc);
figure(4)
plot(hc,gamma_an,'b-')
hold on
plot(hc,gamma_iso,'r-','linewidth',2)
plot(hc,gamma_synth,'k-','linewidth',2)
hold off
;xlabel('Distance');ylabel('\gamma')
legend(num2str(ang_array'))
