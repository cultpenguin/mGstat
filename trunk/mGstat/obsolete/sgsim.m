% sgsim : Sequential Gaussian SIMulation 
%
%
%
function [simdata]=sgsim(pos_known,val_known,pos_est,V,options);
  
  if nargin==4
    options.max=5;
  end
  
  n_est=size(pos_est,1);
  
  if isfield(options,'nsim')
    nsim=options.nsim;
  else
    nsim=1;
  end
  
  d_est=zeros(n_est,nsim);
  
  % PreCalculate Covariance lookup table
  CovMat=precal_cov([pos_known;pos_est],[pos_known;pos_est],V);
  
  npos_known=size(pos_known,1);
  npos_est=size(pos_est,1);
  
  simdata=zeros(n_est,nsim).*NaN;
  
  pos_known_orig=pos_known;
  val_known_orig=val_known;
  
  tic
    for isim=1:nsim
      
      pos_known=pos_known_orig;
      val_known=val_known_orig;
      
      % calculate randompath 
      rpath=[rand(1,n_est);1:1:n_est]';
      rpath=sortrows(rpath,1);
      rpath=rpath(:,2);
      
      for i=1:n_est
        t=toc;
        % progress bar
        if t>.1
          try 
          if (i/di)==round(i/di)
            i1=(isim-1)*n_est+i;
            i1max=n_est*nsim;
            txt1=sprintf('%s sim%2d : ',mfilename,isim);
            txt2=sprintf('%s       : ',mfilename);
            progress_txt([i,i1],[n_est,i1max],txt1,txt2);
          end
          catch
            di=i;
          end
        end
        % get current position
      cpos = rpath(i); 
      
      % Update covariance from loolup table
      options.d2d = CovMat([1:npos_known,npos_known+rpath(1:(i-1))'],[1:npos_known,npos_known+rpath(1:(i-1))']);    
      options.d2u = CovMat([1:npos_known,npos_known+rpath(1:(i-1))'],npos_known+cpos);    
      
      % calculate local cpdf (kriging)
      [de,dv,l,K,k]=krig(pos_known,val_known,pos_est(cpos,:),V,options);
      
      % draw a value from the gaussian cpdf
      d_draw=norminv(rand(1),de,dv);
      
      % add simulated data to list of known data
      % THE FOLLOWING IS REALLY BAD PRORGRAMMING
      % WORKS ONLY FOR VERY SMALL MATRICES !!!
      pos_known=[pos_known;pos_est(cpos,:)];
      val_known=[val_known;d_draw 0];
      
      % save simulated data for output
      simdata(cpos,isim)=d_draw;
      
    end % loop over nodes
    
    
  end % loop over simulations
  
  
  
  