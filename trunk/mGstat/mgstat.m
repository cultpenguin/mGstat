% mgstat : geostatistical ..
%
% CALL : mgstat(G)
%    G : mgstat data structure OR gstat parameter file on disk
%
%        [pred,pred_var,pred_covar,mask,G]=mgstat(G)
%
function [pred,pred_var,pred_covar,mask,G]=mgstat(G)

  
  gstat=mgstat_binary;
  
  % check if input is STRUCTURE or FILE
  if isstruct(G)==1,
    gstat_filename=write_gstat_par(G);
  else
    gstat_filename=G;
    G=read_gstat_par(gstat_filename);
  end
  
  [s,w]=system([gstat,' ',gstat_filename]);
  
  
  
  
  % RETURN PREDICTIONS OF SET
  if nargout>0
    if isfield(G,'predictions')
      for ip=1:length(G.predictions)
        mgstat_convert(G.predictions{ip}.file);
        
        if exist(G.predictions{ip}.file)==2;
          % [pred{ip},x,y,dx,nanval]=read_gstat_ascii([G.predictions{ip}.file,'.ascii']);
          [pred{ip},x,y,dx,nanval]=read_arcinfo_ascii([G.predictions{ip}.file,'.ascii']);
        else
          pred{ip}=[];mgstat_verbose(sprintf('Cannot find "%s"',G.predictions{ip}.file));
        end
      end
      %if ip==1, pred=pred{1};end
    else
      pred=[];mgstat_verbose(sprintf('NO PREDICTION FILE SET'));
    end
  end
  
  
  % RETURN VARIANCES
  if nargout>1
    if isfield(G,'variances')
      for ip=1:length(G.variances)
        mgstat_convert(G.variances{ip}.file);
        
        if exist(G.variances{ip}.file)==2;
          % [pred_var{ip},x,y,dx,nanval]=read_gstat_ascii([G.variances{ip}.file,'.ascii']);
          [pred_var{ip},x,y,dx,nanval]=read_arcinfo_ascii([G.variances{ip}.file,'.ascii']);
        else
          pred_var{ip}=[];mgstat_verbose(sprintf('Cannot find "%s"',G.variances{ip}.file));
        end
      end
      %if ip==1, pred_var=pred_var{1};end
    else
      pred_var=[];mgstat_verbose(sprintf('NO VARIANCE FILE SET'));
    end
  end
  
  % RETURN COVARIANCES
  if nargout>2
    if isfield(G,'covariances')
      for ip=1:length(G.covariances)
        mgstat_convert(G.covariances{ip}.file);
        
        if exist(G.covariances{ip}.file)==2;
          % [pred_covar{ip},x,y,dx,nanval]=read_gstat_ascii([G.covariances{ip}.file,'.ascii']);
          [pred_covar{ip},x,y,dx,nanval]=read_arcinfo_ascii([G.covariances{ip}.file,'.ascii']);
        else
          pred_covar{ip}=[];mgstat_verbose(sprintf('Cannot find "%s"',G.covariances{ip}.file));
        end
      end
      %if ip==1, pred_covar=pred_covar{1};end
    else
      pred_covar=[];mgstat_verbose(sprintf('NO COVARIANCE FILE SET'));
    end
  end
  
  
  % RETURN MASK
  if nargout>3
    if isfield(G,'mask')
      for ip=1:length(G.mask)
        mgstat_convert(G.mask{ip}.file);
        
        if exist(G.mask{ip}.file)==2;
          % [mask{ip},x,y,dx,nanval]=read_gstat_ascii([G.mask{ip}.file,'.ascii']);
          [mask{ip},x,y,dx,nanval]=read_arcinfo_ascii([G.mask{ip}.file,'.ascii']);
        else
          mask{ip}=[];mgstat_verbose(sprintf('Cannot find "%s"',G.mask{ip}.file));
        end
      end
      %if ip==1, mask=mask{1};end
    else
      mask=[];mgstat_verbose(sprintf('NO MASK FILE SET'));
    end
  end
