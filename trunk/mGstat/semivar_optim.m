function Voptim=semivar_optim(loc,val,bin_array,V,doPlot);

    
  if nargin<3, 
    bin_array=linspace(0,10,100);
  end
  
  if nargin<4
    V='1 Exp(1.5)';
  end

  if exist('fminsearch')~=2
    mgstat_verbose(sprintf('%s : COULD NOT FIND OPTIMIZATION TOOLBOX .. exiting',mfilename))
    Voptim=V;
  end

  if nargin<5
    doPlot=0;
  end
  
      
  if ischar(V)
    V=deformat_variogram(V);
  end
  
  mgstat_verbose(sprintf('%s : Optimizing',mfilename),0);
  
  % FIRST GET THE OBSERVED SEMIVARIOGRAM  
  [h,sv_obs]=semivar(loc,val,bin_array);
  save semivar_optim_dummy h sv_obs

  % GET THE INTIAL VARIOGRAM
  [sv_init]=semivar_synth(V,h);
  
  
  
  CreateMisfitFunction(V,h,'semivar_optim_dummy')
  
  ipar=0;
  for i=1:length(V);
    ipar=ipar+1;pars(ipar)=V(i).par1;
    ipar=ipar+1;pars(ipar)=V(i).par2;
  end
  
  % Now optimize the variogram using Matlab OPTIMIZATION toolbox
  %options = optimset('GradObj','off','MaxFunEvals',10000);
  %options = optimset('MaxFunEvals',10000);
  options=optimset;
  pars_optim=fminsearch('GstatOptim',pars);

  Voptim=V;
  ipar=0;
  for i=1:length(V);
    ipar=ipar+1;Voptim(i).par1=pars_optim(ipar);
    ipar=ipar+1;Voptim(i).par2=pars_optim(ipar);
  end

  [sv_optim]=semivar_synth(Voptim,h);
  
  if doPlot==1,
    plot(h,[sv_obs;sv_init;sv_optim],'-');legend({'Obs','Init','Optim'});
    title(format_variogram(Voptim));
    drawnow
  end
  
