% Example : Example_UseOfNormalScore
%
% Example of using normal score transformation in Matlab, while
% using GSTAT for kriging.
%
%


% LOAD DATA
[data,header]=read_eas('prediction.dat');
x_obs=data(:,1);
y_obs=data(:,2);
iuse=10;
d_obs=data(:,iuse);
n=size(data,1);


% FIRST MODEL THE NORMAL SCORE

% normalscore transform
w1=2; dmin=-.1; % interpolation options for lower tail 
w2=.5; dmax=max(d_obs).*1.2;% interpolation options for upper tail 
                           % See Goovaerts page 280 for more.
figure;
[d_nscore,o_nscore]=nscore(d_obs,w1,w2,dmin,dmax);

% write data to gstat
write_eas('Nscore.eas',[x_obs,y_obs,d_nscore(:)]);

return

% SECOND, INFER THE VARIOGRAM MODEL AND CREATE A 
% GSTAT COMMAND FILE


%%%
%%%
%%% CALL GSTAT
[pred,var,dum1,dum2,G]=mgstat('Example_UseOfNormalScore.cmd');
%%%
%%%
%%%

% read mask
[mask,x,y]=read_arcinfo_ascii(G.mask{1}.file);


% INVERS NORMAL SCORE TRANSFORM
d_out=inscore(pred{1},o_nscore);

% dont plot kriging estimated for high variance values
d_out(find(var{1}>.9))=NaN;


figure;

imagesc(x,y,d_out);
hold on
%plot(x_obs,y_obs,'k.','markerSize',41);
scatter(x_obs,y_obs,40,d_obs);
hold off
set(gca,'ydir','normal')
colorbar
axis image
title(['kriging using the normal score transform - ',header{iuse}])
