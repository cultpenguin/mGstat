% Example : Example_UseOfNormalScore
%
% Example of using normal score transformation in Matlab, while
% using GSTAT for kriging.
%
%

% Load data
[data,header]=read_eas('prediction.dat');


x_obs=data(:,1);
y_obs=data(:,2);
z_obs=x_obs.*0; % CREATING DUMMY Z TO MIMIC 3D DATA
iuse=6;
d_obs=data(:,iuse);

% WRITE 3D OBSERVATIONS TO DATA FILE :
H{1}='x';H{2}='y';H{3}='z';H{4}='val';
write_eas('3dobs.eas',[x_obs y_obs z_obs d_obs]);

% CREATE A FILE OF 3D POINTS TO BE ESTIMATED 
% TO USE GSTAT IN 3D YOIU HAVE TO SPECIFY 
% AN 'EAS', AND NOT THE MASK AS USUAL.
% FIRST : SELECT THE X,Y,Z RAGES TO ESTIMATE
x_est=linspace(min(x_obs),max(x_obs),55);
y_est=linspace(min(x_obs),max(x_obs),30);
z_est=linspace(-1.2,1.2,8);
[xx,yy,zz]=meshgrid(x_est,y_est,z_est);
% WRITE THE ESTIMATION LOCATIONS TO AN EAS FILE
write_eas('3dest.eas',[xx(:) yy(:) zz(:)],H);

%% READY TO PERFORM KRIGING
%% (TAKE A LOOK AT THE GSTAT CMD FILE)
! gstat gstat_3d.cmd

% READ DATA INTO MATLAB
G=read_gstat_par('gstat_3d.cmd');
[d,h]=read_eas(G.set.output);
% PLOT DATA USING SCATTER3
scatter3(d(:,1),d(:,2), d(:,3),30,d(:,4),'filled')
xlabel('X');ylabel('Y');zlabel('Z');title('3D KRIGING')
colorbar

% PLOT ONLY DATA WITH RELATIVELY SMALL VARIANCE
figure
iplot=find(d(:,5)< 0.95*max(d(:,5)) );
scatter3(d(iplot,1),d(iplot,2), d(iplot,3),30,d(iplot,4),'filled')
xlabel('X');ylabel('Y');zlabel('Z');title('3D KRIGING (masked)')
colorbar;

% SCATTER PLOTS MAY NOT BE THW BEST WAY TO VISUALIZE 3D DATA
% HERE IS HOW TO CONVERT DATA TO a 3D DATA CUBE
nx=length(x_est);
ny=length(y_est);
nz=length(z_est);
dcube=reshape(d(:,4),ny,nx,nz);
vcube=reshape(d(:,5),ny,nx,nz);

% SHOW SLICES THROUGH CUBE :
figure
slice(x_est,y_est,z_est,dcube,x_est([nx]),y_est(30),z_est(4))
xlabel('X');ylabel('Y');zlabel('Z');
colorbar;
% shading interp
% MAKES SURE THAT ASPECT RATIO IS THE SAME FOR ALL AXIS
daspect([1 1 1])


