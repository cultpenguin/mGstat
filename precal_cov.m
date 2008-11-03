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
% Ex:
% x=[1:1:10];
% y=[1:1:20];
% [xx,yy]=meshgrid(x,y);
% cov=precal_cov([xx(:) yy(:)],[xx(:) yy(:)],'1 Sph(5,.1,0)');
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

  for iv=1:length(V)
      par2=V(iv).par2;
      if length(par2)>1
          y_scale=par2(2);
          V(iv).par2=par2(1);
          try 
              if par2(3)~=0
                  mgstat_verbose(sprintf('Rotation not supported, setting rot=0'),mfilename,10)
              end
          end
      else
          y_scale=1;
      end
  end
  
  try
      pos1(:,2)=pos1(:,2)./y_scale;
      pos2(:,2)=pos2(:,2)./y_scale;
  end
  
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
        if k==nparts
            k2=n_est1;
        else
            k2=min([k*nn n_est1]);
        end
        try
            cov(k1:k2,:) = cov(k1:k2,:) + semivar_synth(V(iV),d(k1:k2,:),0);
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

    