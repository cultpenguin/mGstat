% precal_cov : Precalculate covariance matrix
%
% CALL : 
%   cov=precal_cov(pos1,pos2,V);
%
% pos1   [ndata1,ndims] : Location of data to be estimated
% pos2   [ndata2,ndims] : Location of data to be estimated
% V [struct] : Variogram structure
%
% cov [ndata1,ndata1] : Covariance matrix
%

function cov=precal_cov(pos1,pos2,V);
  
  n_est1=size(pos1,1);
  n_est2=size(pos2,1);
  
  cov=zeros(n_est1,n_est2);
  d=zeros(n_est1,n_est2);
  mgstat_verbose([mfilename,' : Setting up covariance']);
  tic
    for i=1:n_est1;
      t=toc;
      % progress bar
      if t>0.1
        try 
          if (i/di)==round(i/di)
            progress_txt(i,n_est1,sprintf('%s : ',mfilename));
          end
        catch
          di=i;
        end
      end
      for j=1:n_est2;
        d(i,j)=edist(pos1(i,:),pos2(j,:),V(1).par2);
      end
    end
    gvar=sum([V.par1]);
    try
      cov=gvar-semivar_synth(V,d);
    catch
      keyboard
    end
    