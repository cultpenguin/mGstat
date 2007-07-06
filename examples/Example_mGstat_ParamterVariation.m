% Example : Example_mGstat_ParameterVariation
%
% An example of using mGstat to run GSTAT from within Matlab
%

parfile='Cd.cmd';
G=read_gstat_par(parfile);

% READ MASK TO GET DIMENSIONS
[mask,x,y,dx,nanval,x0,y0,xll,yll]=read_arcinfo_ascii(G.mask{1}.file);

% GET DATA 
[data,header]=read_eas(G.data{1}.file);
x_obs=data(:,G.data{1}.x);
y_obs=data(:,G.data{1}.y);
v_obs=data(:,G.data{1}.v);

usemax=[3,5,10,20,40,60];
%usemax=[3,5];
n_usemax=length(usemax);
figure(1);
for i=1:n_usemax;
  
  % CHANGE A GSTAT PARAMETER
  G.data{1}.max=usemax(i);
  
  tic % TIME THE RUNNING TIME OF GSTAT
  % RUN GSTAT
  [p,v]=mgstat(G);
  mgstat_exe_time(i)=toc;
  txt=sprintf('max=%d --> exec time of %5.2g seconds',usemax(i),mgstat_exe_time(i));
  disp(txt)
  
  
  % SAVE PREDCICTIONS AND VARIANCES IN MATLAB STRUCTURE
  pred{i}=p{1};
  var{i}=v{1};
  
  % PLOT PREDICTIONS AND VARIANCES
  
  subplot(2,n_usemax,i)
  pred{i}(find(var{i}>0.9*G.variogram{1}.V.par1))=NaN;
  imagesc(x,y,pred{i});axis image
  caxis([6 15])
  set(gca,'Ydir','normal')
  title(sprintf('MAX=%d',usemax(i)))
  
  subplot(2,n_usemax,i+n_usemax)
  imagesc(x,y,var{i});axis image
  caxis([0 1])
  set(gca,'Ydir','normal')

  drawnow
  
end
suptitle('EFFECT OF VARIATION OG NEIGHBORHOOD')

% PLOT PROFILES
figure(2)
iy=round(length(y)/2);
col=jet(n_usemax);
for i=1:n_usemax;
  plot(x,pred{i}(iy,:),'color',col(i,:),'LineWidth',3); 
  hold on; 
  L{i}=num2str(usemax(i));
end;
hold off
legend(L)
xlabel('X')
title(sprintf('Profile at y=%5.2g',y(iy)))

% PRINT EXECUTION TIME TO SCREEN
for i=1:n_usemax;
  txt=sprintf('max=%d --> exec time of %5.2g seconds',usemax(i),mgstat_exe_time(i));
  disp(txt)
end