% visim_tomograhy_linearize
%
%  [Vout,Vlsq]=visim_tomography_linearize(V,S,R,t,t_err,m0,options);
% 
function [Vout,Vlsq]=visim_tomography_linearize(V,S,R,t,t_err,m0,options);

  if nargin<7
    options='';
  end
  
  if ~isfield(options,'freq');options.freq = 1;end
  if ~isfield(options,'doPlot');options.doPlot = 1;end
  if ~isfield(options,'maxit');options.maxit = 10;end
  if ~isfield(options,'step');options.step = 0.1;end
  if ~isfield(options,'min_change');options.min_change = 0.002.*V.gmean;end
  
  nsim=V.nsim;
  densitypr=V.densitypr;
  parfile=V.parfile;
  
  m_new=m0;

  if options.doPlot==1;
    figure(1);
    clf;
  end
  
  for it=1:options.maxit
    disp(sprintf('%s : linearizing iteration %d/%d',mfilename,it,options.maxit))
    if it==1;
      Vlsq{it}=V;
    else
      Vlsq{it}=Vlsq{it-1};
      Vlsq{it}.parfile=sprintf('%s_lin_%d',options.name,it);
      name = sprintf('%s_lin_%d',options.name,it);
      [Vlsq{it},G,Gray,rayl]=visim_setup_tomo_kernel(Vlsq{it},S,R,m_new,t,t_err,name,options);
    end	
    
    Vlsq{it}.nsim=0;
    Vlsq{it}.densitypr=0;
    disp(sprintf('%s : linearizing iteration %d/%d LSQ %s',mfilename,it,options.maxit,Vlsq{it}.parfile))
    Vlsq{it}=visim(Vlsq{it});
    m_curr = Vlsq{it}.etype.mean;

    md = m_curr - m_new;
    mean_change(it) = mean(abs(md(:)));
    
    m_new = m_new + options.step.*(m_curr-m_new);
    
    disp(sprintf('%s : linearizing iteration %d/%d',mfilename,it,options.maxit))
    if (options.min_change>mean_change)
      break
    end
    
    if options.doPlot==1;
      figure(1);
      cax=[-1 1].*(2*sqrt(V.gvar))+V.gmean;
      subplot(3,options.maxit,it);imagesc(V.x,V.y,m_curr');axis image;caxis(cax)
      title('V_{curr}')
      subplot(3,options.maxit,it+options.maxit);imagesc(V.x,V.y,m_new');axis image;caxis(cax)
      title('V_{new}')
      subplot(3,options.maxit,it+2*options.maxit);
      visim_plot_kernel(Vlsq{it});
      drawnow;
      
    end	
  end
  
  Vout=Vlsq{it};
  Vout.nsim=nsim;
  Vout.densitypr=densitypr;
  Vout.parfile=parfile;
  
  
  
