% dssim : Direct Sequential SIMulation 
%         using histogram reproduction (Deutsch 2000, Oz et. al. 2003)
%
%

function [simdata]=dssim(pos_known,val_known,pos_est,V,options);
  
  if nargin==4
    options.max=5;
  end
  
  n_est=size(pos_est,1);
  
  if isfield(options,'nsim')
    nsim=options.nsim;
  else
    nsim=1;
  end

  if isfield(options,'target_hist')==0
    options.target_hist=randn(1,1000);
  end

  d_est=zeros(n_est,nsim);

  % PreCalculate GaussTrans lookup table

  [d_nscore,o_nscore]=nscore(options.target_hist,.5,.5,min(options.target_hist)-0.01,max(options.target_hist)+0.01);
  gmean_arr=[-3.5:.1:3.5];
  gvar_arr=[0.1:0.1:2];
  ngm=length(gmean_arr);
  ngv=length(gvar_arr);
  ng=100;
  for i=1:length(gmean_arr);
    progress_txt([i],[length(gmean_arr)],'Lookup Local CPDF')
    for j=1:length(gvar_arr);
      % progress_txt([i j],[length(gmean_arr) length(gvar_arr)],'mean','var')
      dgauss=gmean_arr(i)+randn(1,ng).*sqrt(gvar_arr(j));
      dhist=inscore(dgauss,o_nscore);
      MulG(i,j).hist=dhist;
      MulG(i,j).mean=mean(dhist);
      MulG(i,j).var=var(dhist);
      n=length(dhist);
      in=1/n;
      MulG(i,j).quan=[1:1:n]./n-in/2;
      MulG(i,j).cpdf=sort(dhist);
    end
  end

  
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
      
      
      % find close cond hist fro mllokup table
      p_var=([MulG.var]-dv);
      p_var=p_var./(max(p_var)-min(p_var));
      p_mean=([MulG.mean]-de);
      p_mean=p_mean./(max(p_mean)-min(p_mean));
      dis=([p_mean.^2 + p_var.^2]);loc=find(dis==min(dis));
      [i_m,i_v]=ind2sub([ngm ngv],loc);
      %scatter([MulG.mean],[MulG.var],80,[MulG.var],'filled')
      %hold on
      %plot(MulG(i_m,i_v).mean,MulG(i_m,i_v).var,'kx')
      %hold off
      %disp(sprintf('Using hist for (m,v)=(%5.2f,%5.2f)',MulG(i_m,i_v).mean,MulG(i_m,i_v).var))
      %disp(sprintf('          True (m,v)=(%5.2f,%5.2f)',de,dv))
 
      
      % DRAW FROM LOOKED UP HISTOGRAM
      %
      

      try
        % draw from local cpdf (use lookup table
        d_draw=interp1(MulG(i_m,i_v).quan,MulG(i_m,i_v).cpdf,rand(1));
      catch
        disp(sprintf('Some trouble de=%4.2f dv=%4.2f i_m=%d i_v=%d',de,dv,i_m,i_v))
        % draw a value from the gaussian cpdf
        d_draw=norminv(rand(1),de,dv)
      end
      
      if isnan(d_draw)
        d_draw=norminv(rand(1),de,dv);
        disp(sprintf('Some trouble de=%4.2f dv=%4.2f i_m=%d i_v=%d',de,dv,i_m,i_v))
      end      
      
      % add simulated data to list of known data
      % THE FOLLOWING IS REALLY BAD PRORGRAMMING
      % WORKS ONLY FOR VERY SMALL MATRICES !!!
      pos_known=[pos_known;pos_est(cpos,:)];
      val_known=[val_known;d_draw 0];
      
      % save simulated data for output
      simdata(cpos,isim)=d_draw;
      
    end % loop over node
    
    
  end % loop over simulations
  
  
  
  