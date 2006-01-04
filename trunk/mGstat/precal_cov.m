% precal_cov : Precalculate covariance matrix
%
% CALL : 
%   cov=precal_cov(pos1,pos2,V,options);
%
% pos1   [ndata1,ndims] : Location of data to be estimated
% pos2   [ndata2,ndims] : Location of data to be estimated
% V [struct] : Variogram structure
%
% cov [ndata1,ndata1] : Covariance matrix
%

function cov=precal_cov(pos1,pos2,V,options);
  
  options.dummy='';
  % DETERMINE ISORANGE
  if  any(strcmp(fieldnames(options),'isorange'))
    isorange=options.isorange;
  else
    isorange=0;
  end

  n_est1=size(pos1,1);
  n_est2=size(pos2,1);
  
  cov=zeros(n_est1,n_est2);
  d=zeros(n_est1,n_est2);
  mgstat_verbose([mfilename,' : Setting up covariance']);

  gvar=sum([V.par1]);

  tic
    for iV=1:length(V)
    for i=1:n_est1;
      t=toc;
      % progress bar
      if t>0.3
        try 
          if (i/di)==round(i/di)
            progress_txt(i,n_est1,sprintf('%s : ',mfilename));
          end
        catch
          di=i;
        end
      end
      for j=1:n_est2;
        d(i,j)=edist(pos1(i,:),pos2(j,:),V(iV).par2,isorange);
      end
    end
    cov = cov + semivar_synth(V(iV),d);
    end

    cov=gvar-cov;

    