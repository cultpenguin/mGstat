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
  
  % PreCalculate D2D
  CovMat=precal_cov([pos_known;pos_est],[pos_known;pos_est],V);
  npos_known=size(pos_known,1);
  npos_est=size(pos_est,1);
  
  %options.d2d=precal_cov(pos_known,pos_known,V);

  % PreCalculate D2U
  %options.d2u=precal_cov(pos_known,pos_est,V);

  
  simdata=zeros(n_est,nsim).*NaN;

  
  profile on
  
  for isim=1:nsim
    
    % calculate randompath
    rpath=[rand(1,n_est);1:1:n_est]';
    rpath=sortrows(rpath,1);
    rpath=rpath(:,2);
    
    for i=1:n_est
      % progress bar
      progress_txt((isim-1)*n_est+i,n_est*nsim,sprintf('%s : ',mfilename));
      
      % get current position
      cpos = rpath(i); 

      % calculate local cpdf (kriging)
      
      options.d2d = CovMat([1:npos_known,npos_known+rpath(1:(i-1))'],[1:npos_known,npos_known+rpath(1:(i-1))']);    
      
      [de,dv,l,K,k]=krig(pos_known,val_known,pos_est(cpos,:),V,options);
            
      
      disp(de)
      
      % draw a value from the gaussian cpdf
      d_draw=norminv(rand(1),de,dv);
      
      % add simulated data to list of known data
      %pos_known=[pos_known;pos_est(cpos,:)];
      %val_known=[val_known;d_draw 0];
      
      % save simulated data for output
      simdata(cpos,isim)=d_draw;
      simdata(cpos,isim)=de;

      
      % 
      
    end
    
    
  end
  
  
  profile viewer
  
  
  
  