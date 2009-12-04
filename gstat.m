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
    % SET PRECISION IF NOT ALLREADY SET
    %if ~isfield(G.set,'precision');
    %    G.set.format='%16.8f';
    %    G.set.format='%20.10f';
    %end
    if ~isfield(G.set,'mv')
        G.set.mv='-999';
    end
    write_gstat_par(G);
    G=read_gstat_par(G.mgstat.parfile);
end



mgstat_verbose(sprintf('Trying to run GSTAT on %s',gstat_filename),-1)
if isunix
    [s,w]=system([gstat_bin,' ',gstat_filename]);
else
    [s,w]=system(sprintf('"%s" %s',gstat_bin,gstat_filename));
end
mgstat_verbose(w,3);
mgstat_verbose(sprintf('Finished running GSTAT on %s',gstat_filename),1)


if ~isempty(regexp(w,'fail'))
    mgstat_verbose('GSTAT FAILED ............',-1)
    p=[];v=[];
    return
end

% If estimating/simulating using a location file (NO MASK)
if ((~isfield(G,'mask'))&(isfield(G,'set')))
    if isfield(G.set,'output')
        mgstat_verbose(sprintf('%s : reading output data from %s',mfilename,gstat_filename),1)
        
        % get Dimensions
        for id=1:length(G.data)
            if isfield(G.data{id},'x'), ndim=1; ix=G.data{id}.x; end
            if isfield(G.data{id},'y'), ndim=2; iy=G.data{id}.y; end
            if isfield(G.data{id},'z'), ndim=3; iz=G.data{id}.z; end
            if isfield(G.data{id},'file'), dfile=G.data{id}.file; end
        end
        % Read Data
        try
            [d]=read_eas(G.set.output);
        catch
            mgstat_verbose(sprintf('%s : Failed to read %s',mfilename,G.set.output),-1);
            return;
        end
        % read locations
        [loc]=read_eas(dfile);
        
        nsim=0;
        if isfield(G,'set')
            if (isfield(G.set,'nsim')),
                nsim=G.set.nsim;
            end
        end
        
        if nsim==0
            pred=d(:,ndim+1);
            pred1=pred;
            pred_var=d(:,ndim+2);
            try
                pred_covar=d(:,ndim+2);
            catch
                pred_covar=[];
            end
        else
            pred=d(:,(ndim+1):(ndim+nsim));
        end
        
        
        mask=[];
    end
end

if (isfield(G,'mask'))
    
    
    %% READ MASK DATA
    %% READ PREDICTIONS
    if nargout>0
        if isfield(G,'predictions')
            mgstat_verbose(sprintf('%s : reading predictions from %s',mfilename,gstat_filename),1)
            
            nsim=1; % DEFAULT ONLY ONE SIM/ESTIMATION
            % FIND NUMBER OF SIMULATIONS
            if isfield(G,'set')
                if (isfield(G.set,'nsim')),
                    nsim=G.set.nsim;
                end
            end
            for ip=1:length(G.predictions)
                % LOOP OVER NUMBER OF PREDICTION LINES
                for isim=1:nsim
                    file=G.predictions{ip}.file;
                    if nsim>1,
                        if nsim<100
                            file=sprintf('%s%2d',file,isim-1);
                        elseif nsim<1000
                            file=sprintf('%s%3d',file,isim-1);
                        else
                            file=sprintf('%s%4d',file,isim-1);
                        end
                        file=regexprep(file,' ','0');
                    end
                    
                    if exist(file)==2;
                        %[pred{ip,isim},x,y,dx,nanval]=read_arcinfo_ascii(file);
                        [pred(:,:,ip),x,y,dx,nanval]=read_arcinfo_ascii(file);
                    else
                        pred{ip,isim}=[];mgstat_verbose(sprintf('Cannot find "%s"',file),1);
                    end
                end
            end
        else
            pred=[];mgstat_verbose(sprintf('NO PREDICTION FILE SET'),1);
        end
    end
    
    %% RETURN VARIANCES
    if nargout>1
        if isfield(G,'variances')
            mgstat_verbose(sprintf('%s : reading variances data from %s',mfilename,gstat_filename),1)
            
            for ip=1:length(G.variances)
                %gstat_convert(G.variances{ip}.file);
                
                if exist(G.variances{ip}.file)==2;
                    %[pred_var{ip},x,y,dx,nanval]=read_arcinfo_ascii(G.variances{ip}.file);
                    [pred_var(:,:,ip),x,y,dx,nanval]=read_arcinfo_ascii(G.variances{ip}.file);
                else
                    pred_var{ip}=[];mgstat_verbose(sprintf('Cannot find "%s"',G.variances{ip}.file));
                end
            end
        else
            pred_var=[];mgstat_verbose(sprintf('NO VARIANCE FILE SET'),1);
        end
    end
    
    %% RETURN COVARIANCES
    if nargout>2
        if isfield(G,'covariances')
            mgstat_verbose(sprintf('%s : reading covariances data from %s',mfilename,gstat_filename),1)
            
            for ip=1:length(G.covariances)
                %gstat_convert(G.covariances{ip}.file);
                
                if exist(G.covariances{ip}.file)==2;
                    %[pred_covar{ip},x,y,dx,nanval]=read_arcinfo_ascii(G.covariances{ip}.file);
                    [pred_covar(:,:,ip),x,y,dx,nanval]=read_arcinfo_ascii(G.covariances{ip}.file);
                else
                    pred_covar{ip}=[];mgstat_verbose(sprintf('Cannot find "%s"',G.covariances{ip}.file));
                end
            end
        else
            pred_covar=[];mgstat_verbose(sprintf('NO COVARIANCE FILE SET'),1);
        end
    end
    
    %% RETURN MASK
    if nargout>3
        if isfield(G,'mask')
            for ip=1:length(G.mask)
                
                if exist(G.mask{ip}.file)==2;
                    [mask{ip},x,y,dx,nanval]=read_arcinfo_ascii(G.mask{ip}.file);
                else
                    mask(:,:,ip)=[];mgstat_verbose(sprintf('Cannot find "%s"',G.mask{ip}.file));
                end
            end
        else
            mask=[];mgstat_verbose(sprintf('NO MASK FILE SET'),1);
        end
    end
end
