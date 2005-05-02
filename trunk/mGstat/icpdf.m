% icdf : inverse cimulative density function
%
% find data value associated to an pk quantile.
%
% CALL : d_obs=icdf(data,pk_obs)
%   
%
function d_obs=icdf(alldata,pk_obs,doPlot)

  if nargin<3
    doPlot=1;
  end

  if nargin==1
    pk_obs=[0.1:.1:.9];
    disp('Using pk=0.1,0.2,...,0.9')
  end
  
  
  % SORT DATA
  sd=sort(alldata(:)-.000001*rand(size(alldata)));
  nd=length(sd);
  
  dk=1/nd;
  pk=(-1/(2*nd))+[1:1:nd]./nd;
  
  % INTERPOLATE TO FIND pk VALUES of d
  d_obs = interp1(pk,sd,pk_obs);
  
  if doPlot==1;
    plot(sd,pk,'k-*')
    hold on
    plot(d_obs,zeros(size(d_obs)),'r*')
    plot(zeros(size(pk_obs)),pk_obs,'g*')
    for i=1:length(d_obs)
      plot([d_obs(i) d_obs(i)],[0 pk_obs(i)],'r-')
      plot([0 d_obs(i)],[pk_obs(i) pk_obs(i)],'g-')
    end
    
    hold off
  end

  