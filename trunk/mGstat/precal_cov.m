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

  if ~isstruct(V);
      V=deformat_variogram(V);
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
      if t>0
          di=100;
          if (i/di)==round(i/di)

              progress_txt([i iV],[n_est1 length(V)],sprintf('%s : ',mfilename),'Nested struture');
          end
      end
      
      % NEW VECTORIZED APPROACH
      jj=1:n_est2;;
      p1=repmat(pos1(i,:),length(jj),1)';
      p2=pos2(jj,:)';
      dd=edist(p1,p2,V(iV).par2,isorange);
      d(i,:)=dd;
      
      %% OLD METHOD
      %for j=1:n_est2;
      %   d(i,j)=edist(pos1(i,:),pos2(j,:),V(iV).par2,isorange);
      %    
      %end

    end

    
    % SPLIT IN SMALLER SIZES FOR MATLAB
    
    maxsize=1000000;
    nparts=ceil(prod(size(d))/maxsize);
    nn=floor(n_est1/nparts);

    % ALLOCATE COV
    cov=zeros(size(d));
    for k=1:nparts
        progress_txt(k,nparts,'Calculating variance')
        k1=(k-1)*nn+1;
        k2=min([k*nn n_est1]);
        try
            cov(k1:k2,:) = cov(k1:k2,:) + semivar_synth(V(iV),d(k1:k2,:));
        catch
            keyboard
        end
    end
        
    %nn=round(n_est1/2);
    %nn1=nn+1;
    %cov(1:nn,:) = cov(1:nn,:) + semivar_synth(V(iV),d(1:nn,:));
    %cov(nn1:n_est1,:) = cov(nn1:n_est1,:) + semivar_synth(V(iV),d(nn1:n_est1,:));

    
    end

    cov=gvar-cov;

    