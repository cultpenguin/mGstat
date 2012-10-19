% Goovaerts Example : loaddata
%
% simple example, loading the Jura data and plottingf some basic
% stat plots
%

% READ GOOVAERTS PREDICTION DATA
[data,header]=read_eas('prediction.dat');
x=data(:,1);
y=data(:,2);

id=5;
val=data(:,id);

ndata=size(data,1);
ndata=length(x);

ntype=size(data,2);
ntype=length(data);

% open new figure
figure 
% plot data locations
plot(x,y,'.');
% flip y-axis
%set(gca,'ydir','reverse')
% Makes sure axes are proportional
axis image ; 


%%%%%%%%%%%%%%%%%%%%%%%%%%
% Histograms
% simple :
figure
[h,hx]=hist(val);
bar(hx,h./ndata)
title(header{id});xlabel('Concentration (ppm) ');ylabel('Frequency')
% more control
figure
[h,hx]=hist(val,linspace(min(data(:,id)),max(data(:,id)),20));
bar(hx,h./ndata)
title(header{id});xlabel('Concentration (ppm) ');ylabel('Frequency')


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cumulative Frequency
figure
plot(sort(val),[1:1:ndata]./ndata,'.')
xlabel('Conentration (ppm)')
ylabel('Cumulative Frequency')
title(header{id})

figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% location Maps
dmin=min(val);
dmax=max(val);
colorax=[dmin dmax];
scatter(x,y,20,val,'filled')
% flip y-axis
%set(gca,'ydir','reverse')
% Makes sure axes are proportional
axis image ; 
title(header{id})

% Vis summary statistics med 2 decimaler
disp(['SUMMARY STATISTICS for ',header{id}])
disp(sprintf('Mean  =%5.2f',mean(val)))
disp(sprintf('Median=%5.2f',median(val)))
disp(sprintf('Min   =%5.2f',min(val)))
disp(sprintf('Max   =%5.2f',max(val)))
disp(sprintf('Std   =%5.2f',std(val)))
skew = 1/ndata * sum((val-mean(val)).^3)./var(val).^3;
skew = 1/ndata * sum(((val-mean(val)).^3)./(var(val).^3));
disp(sprintf('Skew  =%5.2f',skew ))
  
