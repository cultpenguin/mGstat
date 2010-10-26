% gstat_krig : Simple/Ordinary Kriging using GSTAT
%
% Call :
% [d_est,d_var]=gstat_krig(pos_known,val_known,pos_est,V,options);
%
% ndata : number of data observations
% ndims : dimensions of data location (>=1)
% nest  : number of data locations to be estimated
%
% pos_known [ndata,ndims] : Locations of data observations
% val_known [ndata,1 or 2]  : col1 : Data value as measured at 'pos_known'
%                             col2 : Data uncertainty as measured at
%                             'pos_known' (optional)
% pos_est   [nest ,ndims] : Location of data to be estimated
% V : Variogram model, e.g. '1 Sph(100)'
%
%
% %% Example 1 : 1D - NO DATA UNCERTAINTY
% profile on
% pos_known=10*rand(10,1);
% val_known=rand(size(pos_known)); % adding some uncertainty
% pos_est=[0:.01:10]';
% V=deformat_variogram('1 Sph(1)');
% [d_est,d_var]=gstat_krig(pos_known,val_known,pos_est,V);
% plot(pos_est,d_est,'r.',pos_est,d_var,'b.',pos_known,val_known(:,1),'g*')
% legend('SK estimate','SK variance','Observed Data')
% title(['V = ',V])
% profile viewer
%
%
%
% %% Example 2 : 1D - Data Uncertainty 
% pos_known=[1;5;10];
% val_known=[0 3 2;0.001 1 0.001]'; % adding some uncertainty
% pos_est=[0:.01:10]';
% V='1 Sph(2)';
% [d_est,d_var]=gstat_krig(pos_known,val_known,pos_est,V);
% plot(pos_est,d_est,'r.',pos_est,d_var,'b.',pos_known,val_known(:,1),'g*')
% legend('SK estimate','SK variance','Observed Data')
% title(['using data uncertainty, V = ',V])
%
%
% %% Example 3 : 2D estimation 
% pos_known=[0 1;5 8;10 1];
% val_known=[0 3 2]';
% x=[0:.1:10];
% y=[0:.1:10];
% [xx,yy]=meshgrid(x,y);
% pos_est=[xx(:) yy(:)];
% V='1 Sph(7)';
% [d_est,d_var]=gstat_krig(pos_known,val_known,pos_est,V);
% subplot(1,2,1);scatter(pos_est(:,1),pos_est(:,2),10,d_est)
% axis image;title('Kriging mean')
% subplot(1,2,2);scatter(pos_est(:,1),pos_est(:,2),10,d_var)
% axis image;title('Kriging variance')
%
%
% %% Example 4 :SIMULATION
% pos_known=[0 1;5 1;10 1];
% val_known=[0 3 2]';
% pos_est=linspace(-1,11,200)';pos_est(:,2)=1;
% V='.0001 Nug(0) + .2 Gau(2)';
% [d_est,d_var]=gstat_krig(pos_known,val_known,pos_est,V);
% plot(pos_est(:,1),d_est,'k-',pos_known(:,1),val_known(:,1),'r*')
% 
% options.nsim=120;
% [d_sim,d_varsim,pos_sim]=gstat_krig(pos_known,val_known,pos_est,V,options);
% d=sortrows([pos_sim(:,1) d_sim],1);
% d_sim=d(:,2:(options.nsim+1));
% 
% d=sortrows([pos_sim(:,1) d_varsim],1);
% d_varsim=d(:,2);
% 
% plot(pos_est(:,1),d_sim,'r-');
% 
% hold on
% plot(pos_est(:,1),d_est,'k-','linewidth',4)
% plot(pos_known(:,1),val_known(:,1),'b.')
% 
% plot(pos_est(:,1),d_varsim-4,'k-')
% plot(pos_est(:,1),d_var-4,'r-')
% hold off
% 
%

% TMH/2005
%

function [d_est,d_var,pos_est]=gstat_krig(pos_known,val_known,pos_est,V,options);
  
  if nargin<5
    options.null=0;
  end

  if ischar(V),
    V=deformat_variogram(V);
  end

  if nargin<5
      options.null='';
  end

  % CHECK FOR ISORANGE
  if  ~any(strcmp(fieldnames(options),'isorange'))
    options.isorange=0;
  end

  if options.isorange==1;
    % Reshape the range format to suit GSTAT 
    V=isorange(V);
  end
  
  if (isfield(options,'sk_mean')&isfield(options,'d'))
    mgstat_verbose(sprintf('%s : You have specified both ''sk_mean''  ',mfilename),-1)
    mgstat_verbose(sprintf('%s : and ''d''. GSTAT will not run. ',mfilename))
    return 
  end
  
  % WRITE DATA TO EAS FILES
  if exist([pwd,filesep,',obs.eas'])==2
    delete('obs.eas'); 
  end
  if exist([pwd,filesep,'est.eas'])==2
    delete('est.eas'); 
  end 
  write_eas('obs.eas',[pos_known val_known]);
  write_eas('est.eas',pos_est);
  
  G.mgstat.parfile='gstat.cmd';
  
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
%  if isfield(options,'mv'), % MISSING VALUE
%    G.set.mv=options.mv;
%  else
    G.set.mv=-9e+9;
%  end
  if isfield(options,'omax'),
    G.data{1}.omax=options.omax;
  end
  if isfield(options,'radius'),
    G.data{1}.radius=options.radius;
  end
  if isfield(options,'average'),
    G.data{1}.average='';
  end
  if isfield(options,'every'),
    G.data{1}.every=options.every;
  end
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

  if isfield(options,'nsim')
      G.method{1}.gs='';
      G.set.nsim=options.nsim;
  end


  G.variogram{1}.data='obs';
  G.variogram{1}.V=V;

  G.data{2}.data='';
  G.data{2}.file='est.eas';
  if ndim>0, G.data{2}.x=1; end
  if ndim>1, G.data{2}.y=2; end
  if ndim>2, G.data{2}.z=3; end

  outfile='gstat.out';
  G.set(1).output=outfile;

  %keyboard
  
  %write_gstat_par(G);
  
  gstat(G);

  try
    d=read_eas(outfile);
  catch
    mgstat_verbose(sprintf('%s : Could not read GSTAT output file',mfilename),-1)
    mgstat_verbose(sprintf('%s : GSTAT probably failed !!!',mfilename),-1)
    return
    
  end

  if isfield(options,'nsim')
      pos_est=d(:,1:ndim);
      d_est=d(:,(ndim+1):(ndim+options.nsim));;
      d_var=var(d_est')';
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
  
  
  
  
