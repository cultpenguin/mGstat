% Example_SGSimulation_simple
%


%0.  LOAD DATA
[data,header]=read_eas('prediction.dat');
x_obs=data(:,1);
y_obs=data(:,2);
iuse=5;
d_obs=data(:,iuse);


% 1. SELECT THE NORMAL SCORE TRANSFORM
w1=2;  dmin=0; % interpolation options for lower tail
w2=.5; dmax=6; % interpolation options for upper tail
               % See Goovaerts page 280 for more.
               %  
[d_nscore,o_nscore]=nscore(d_obs,w1,w2,dmin,dmax);

% 3. WRITE NORMAL SCORE DATA TO AN EAS FILE
write_eas('Nscore.eas',[x_obs,y_obs,d_nscore(:)]);


% 4. RUN GSTAT INTERACTIVELY TO LOAD DATA AND PERFOM 
%    VARIOGRAM ANALYSIS
%    YOU NEED TO DO THIS MANUALLY OUTSIDE OF MATLAB
% !gstat -i
%
% FROM HERE ON, IT IS ASSUMED THAT YOU SAVED 
% THE GSTAT COMMANDFILE TO : Nscore.cmd


% 5. SETUP GSTAT 
% read the parameter file 
G=read_gstat_par('Nscore.cmd');
G.data{1}.max=20; % MAKE SURE TO SELECT A NEIGHBORHOOD UNLESS
                  % YOU ARE WILLING TO WAIT FOR A VERY LONG TIME
G.mask{1}.file='JuraMask_0_05.asc'; % select a mask
G.predictions{1}.data=G.data{1}.data; % ONLY IF YOU HAVE NOT SPECIFIED
                                   % THIS IN Nscore.eas
G.predictions{1}.file='sgsim_pred';% ONLY IF YOU HAVE NOT SPECIFIED
                                   % THIS IN Nscore.eas
G.method{1}.gs=''; % select GAUSSIAN SIMULATION 
G.set.nsim=10;% select 10 relizations

% 6 RUN GSTAT
[psim]=mgstat(G);

% 7 BACK TRANSFORM SIMULATED DATA
for isim=1:G.set.nsim
  psim_back{isim}=inscore(psim{isim},o_nscore);
end

% 8 DONE. PLOT THE DATA.
for isim=1:G.set.nsim
  figure;
  imagesc(psim_back{isim})
  axis image
  set(gca,'ydir','normal')
  colorbar
end

