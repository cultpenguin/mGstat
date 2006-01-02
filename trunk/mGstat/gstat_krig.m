% gstat_krig : Simple/Ordinary Kriging using GSTAT
%
% Call :
% [d_est,d_var,lambda_sk,K_dd,k_du,inhood]=gstat_krig(pos_known,val_known,pos_est,V,options);
%
% ndata : number of data observations
% ndims : dimensions of data location (>=1)
% nest  : number of data locations to be estimated
%
% pos_known [ndata,ndims] : Locations of data observations
% val_known [ndata,1 or 2]  : col1 : Data value as measured at 'pos_known'
%                             col2 : Data uncertainty as measured at
%                             'pos_known' (optional)
% pos_est   [1 ,ndims] : Location of data to be estimated
% V : Variogram model, e.g. '1 Sph(100)'
%
%
% Example 1D - NO DATA UNCERTAINTY
% profile on
% pos_known=10*rand(10,1);
% val_known=rand(size(pos_known)); % adding some uncertainty
% pos_est=[0:.01:10]';
% V=deformat_variogram('1 Sph(1)');
% for i=1:length(pos_est);
%   [d_est(i),d_var(i)]=gstat_krig(pos_known,val_known,pos_est(i),V);
% end
% plot(pos_est,d_est,'r.',pos_est,d_var,'b.',pos_known,val_known(:,1),'g*')
% legend('SK estimate','SK variance','Observed Data')
% %title(['V = ',V])
% profile viewer
%
% See source code for more examples
%
%
% Example 1 : 1D - NO DATA UNCERTAINTY
% pos_known=[1;5;10];
% val_known=[0 3 2]'; % adding some uncertainty
% pos_est=[0:.01:10]';
% V='1 Sph(.2)';
% for i=1:length(pos_est);
%   [d_est(i),d_var(i)]=gstat_krig(pos_known,val_known,pos_est(i),V);
% end
% plot(pos_est,d_est,'r.',pos_est,d_var,'b.',pos_known,val_known(:,1),'g*')
% legend('SK estimate','SK variance','Observed Data')
% title(['V = ',V])
%
% Example 2 : 1D - Data Uncertainty 
% pos_known=[1;5;10];
% val_known=[0 3 2;0 1 0]'; % adding some uncertainty
% pos_est=[0:.01:10]';
% V=deformat_variogram('1 Sph(2)');
% for i=1:length(pos_est);
%   [d_est(i),d_var(i)]=gstat_krig(pos_known,val_known,pos_est(i),V);
% end
% plot(pos_est,d_est,'r.',pos_est,d_var,'b.',pos_known,val_known(:,1),'g*')
% legend('SK estimate','SK variance','Observed Data')
% title(['using data uncertainty, V = ',V])
%
%
% Example 3 : 2D : 
% pos_known=[0 1;5 1;10 1];
% val_known=[0 3 2]';
% pos_est=[1.1 1];
% V='1 Sph(2)';
% [d_est,d_var]=gstat_krig(pos_known,val_known,pos_est,V);
%
%

% TMH/2005
%

function [d_est,d_var]=gstat_krig(pos_known,val_known,pos_est,V,options);

  if isstr(V),
    V=deformat_variogram(V);
  end 

  % IF options.iso_range=1;
  V=range_iso2gstat(V);
  
  
  if nargin<5
    options.null=0;
  end
  
  if (isfield(options,'sk_mean')&isfield(options,'d'))
    mgstat_verbose(sprintf('%s : You have specified both ''sk_mean''  ',mfilename),-1)
    mgstat_verbose(sprintf('%s : and ''d''. GSTAT will not run. ',mfilename))
    return 
  end
  
  % WRITE DATA TO EAS FILES
  delete('obs.eas'); 
  delete('est.eas'); 
  write_eas('obs.eas',[pos_known val_known]);
  write_eas('est.eas',pos_est);
  
  G.mgstat.parfile='EsthecKrig.cmd';
  
  G.data{1}.data='obs';
  G.data{1}.file='obs.eas';
  ndim=size(pos_known,2);
  if ndim>0, G.data{1}.x=1; end
  if ndim>1, G.data{1}.y=2; end
  if ndim>2, G.data{1}.z=3; end
  if ndim>3
    mgstat_verbose('GSTAT Does not support more than 3 dimensions')
    return
  end
  G.data{1}.v=(ndim+1);
  if size(val_known,2)>1, G.data{1}.V=ndim+2; end
    

  % PARSE mGstat options to GSTAT
  if isfield(options,'sk_mean'),
    G.data{1}.sk_mean=options.sk_mean;
  end
  if isfield(options,'mean'),
    % FOR mGstat compatability
    G.data{1}.sk_mean=options.mean;
  end
  if isfield(options,'max'),
    G.data{1}.max=options.max;
  end
  if isfield(options,'d'),
    G.data{1}.d=options.d;
  end
  if isfield(options,'polytrend'),
    G.data{1}.d=options.polytrend;
  end

  if isfield(options,'trend'),
    G.method{1}.trend='';
  end

  if isfield(options,'xvalid'),
    G.set(1).xvalid=options.xvalid;
  end
  
  G.variogram{1}.data='obs';
  G.variogram{1}.V=V;

  G.data{2}.data='';
  G.data{2}.file='est.eas';
  if ndim>0, G.data{2}.x=1; end
  if ndim>1, G.data{2}.y=2; end
  if ndim>2, G.data{2}.z=3; end

  outfile='EsthecKrig.out';
  G.set(1).output=outfile;

  write_gstat_par(G);
  gstat(G);

  try
    d=read_eas(outfile);
  catch
    mgstat_verbose(sprintf('%s : Could not read GSTAT output file',mfilename),-1)
    mgstat_verbose(sprintf('%s : GSTAT probably failed !!!',mfilename),-1)
    return
    
  end

  if isfield(options,'xvalid')==1
    if options.xvalid==1
      d_est=d(:,ndim+2);
      d_var=d(:,ndim+3);
    else
      d_est=d(:,ndim+1);
      d_var=d(:,ndim+2);
    end
  else
    d_est=d(:,ndim+1);
    d_var=d(:,ndim+2);
  end
  
  