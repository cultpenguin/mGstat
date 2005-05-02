% cpdf : cumulative probability density function
%
% [pk_obs]=cpdf(alldata,d_obs,doPlot)
%
% finds pk quantiles for data (d_obs), 
% based on a series of data (alldata)
%
%
function [pk_obs]=cpdf(alldata,d_obs,doPlot)

  if nargin<3
    doPlot=1;
  end
  
% SORT DATA
  sd=sort(alldata(:)-.000001*rand(size(alldata)));
  nd=length(sd);
  
  dk=1/nd;
  pk=(-1/(2*nd))+[1:1:nd]./nd;
  
  if nargin==2;
    % INTERPOLATE TO FIND pk VALUES of d
    pk_obs = interp1(sd,pk,d_obs);
  end
  
  if doPlot==1;
    plot(sd,pk,'k-*')
    if nargin>1
      hold on
      plot(d_obs,zeros(size(d_obs)),'r*')
      plot(zeros(size(pk_obs)),pk_obs,'g*')
      for i=1:length(d_obs)
        plot([d_obs(i) d_obs(i)],[0 pk_obs(i)],'r-')
        plot([0 d_obs(i)],[pk_obs(i) pk_obs(i)],'g-')
      end
      
      hold off
    end
end




