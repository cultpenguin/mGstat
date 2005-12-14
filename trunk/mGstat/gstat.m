% gstat : call gstat from Matlab
%
% CALL : gstat(G)
%    G : gstat data structure OR gstat parameter file on disk
%
%        [pred,pred_var,pred_covar,mask,G]=gstat(G)
%
function [pred,pred_var,pred_covar,mask,G]=gstat(G)

  
  gstat_bin=gstat_binary;
  
  % check if input is STRUCTURE or FILE
  if isstruct(G)==1,
    gstat_filename=write_gstat_par(G);
  else
    gstat_filename=G;
    G=read_gstat_par(gstat_filename);
  end
  
  % DELETE ANY EXISTING OUTPUT FILES
  if isfield(G,'set');
    if isfield(G.set,'output');
      if exist(G.set.output)==2
        delete(G.set.output);
      end
    end
  end
  
  mgstat_verbose(sprintf('Trying to run GSTAT on %s',gstat_filename),0)
  [s,w]=system([gstat_bin,' ',gstat_filename]);

  mgstat_verbose(w,1)
  
  if ~isempty(regexp(w,'fail'))
    mgstat_verbose('GSTAT FAILED ............',-1)
    p=[];v=[];
    return
  end
  
 
  % RETURN PREDICTIONS OF SET
  if nargout>0
    if isfield(G,'predictions')
      
      nsim=1; % DEFAULT ONLY ONE SIM/ESTIMATION
      % FIND NUMBER OF SIMULATIONS
      if isfield(G,'set')
        if (isfield(G.set,'nsim')),
          nsim=G.set.nsim;
        end
      end
      for ip=1:length(G.predictions)
        % LOOP OVER NUMBER OF PREDICTION LINES

        % CONVERT GSTAT OUTPUT TO ASCII
        % IT ALLREADY IS SO COMMENTED OUT
        %gstat_convert(G.predictions{ip}.file);
        
        for isim=1:nsim
          file=G.predictions{ip}.file;
          if nsim>1, 
            if isim>10
              file=sprintf('%s%d',file,isim-1);
            else
              file=sprintf('%s0%d',file,isim-1);
            end
          end          
          
          if exist(file)==2;
            [pred{ip,isim},x,y,dx,nanval]=read_arcinfo_ascii(file);
          else
            pred{ip,isim}=[];mgstat_verbose(sprintf('Cannot find "%s"',file),-1);
          end
        end
      end
    else
      pred=[];mgstat_verbose(sprintf('NO PREDICTION FILE SET'));
    end
  end
  
  
  % RETURN VARIANCES
  if nargout>1
    if isfield(G,'variances')
      for ip=1:length(G.variances)
        %gstat_convert(G.variances{ip}.file);
        
        if exist(G.variances{ip}.file)==2;
          [pred_var{ip},x,y,dx,nanval]=read_arcinfo_ascii(G.variances{ip}.file);        
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
        %gstat_convert(G.covariances{ip}.file);
        
        if exist(G.covariances{ip}.file)==2;
          % [pred_covar{ip},x,y,dx,nanval]=read_gstat_ascii([G.covariances{ip}.file,'.ascii']);
          %[pred_covar{ip},x,y,dx,nanval]=read_arcinfo_ascii([G.covariances{ip}.file,'.ascii']);
        [pred_covar{ip},x,y,dx,nanval]=read_arcinfo_ascii(G.covariances{ip}.file);
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
        %gstat_convert(G.mask{ip}.file);
        
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
