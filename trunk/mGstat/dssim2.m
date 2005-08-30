% dssim : Direct Sequential SIMulation 
%         using histogram reproduction (Deutsch 2000, Oz et. al. 2003)
%
%

function [simdata,options]=dssim(pos_known,val_known,pos_est,V,options);

  pos_known_orig=pos_known;
  val_known_orig=val_known;
  
  n_known=size(pos_known,1)
  n_pos_est=size(pos_est,1)

  
  npos_known=size(pos_known,1);
  npos_est=size(pos_est,1);
  

  
  % ALLOCATE SPACE
%  pos_known=zeros(npos_known+npos_est,size(pos_known_orig,2));
 % val_known=zeros(npos_known+npos_est,size(val_known_orig,2));
  
%  pos_known(1:npos_known,:)=pos_known_orig;
%  val_known(1:npos_known,:)=val_known_orig;
  
  
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
  if isfield(options,'MulG')==0,
    [MulG,p]=create_nscore_lookup(options.target_hist);
  else
    MulG=options.MulG;
    p=options.p;
  end
  x_mean=[MulG.x_mean]; % For speed enhancement
  x_var=[MulG.x_var];   % For speed enhancement
  
  % PreCalculate Covariance lookup table
  if isfield(options,'CovMat')==0,
    options.CovMat=precal_cov([pos_known_orig;pos_est],[pos_known_orig;pos_est],V);    
  end
  save options options
  
  simdata=zeros(n_est,nsim).*NaN;
  
  pos_known_init=pos_known;
  val_known_init=val_known;
  
  tic
    for isim=1:nsim
      
      pos_known=pos_known_init;
      val_known=val_known_init;
      
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
        options.d2d = options.CovMat([1:npos_known,npos_known+rpath(1:(i-1))'],[1:npos_known,npos_known+rpath(1:(i-1))']);    
        options.d2u = options.CovMat([1:npos_known,npos_known+rpath(1:(i-1))'],npos_known+cpos);    
        
        % calculate local cpdf (kriging)
        [de,dv,l,K,k]=krig(pos_known,val_known,pos_est(cpos,:),V,options);
        
        % find close cond hist fro mllokup table
        p_mean=(x_mean-de);
        p_var=(x_var-dv);
        dis=([p_mean.^2 + p_var.^2]);
        loc=find(dis==min(dis));
        
        
        
        % DRAW FROM LOOKED UP HISTOGRAM
        %
        %      disp(sprintf('Local Mean = %5.3f (Lookup Mean = %5.3f)',de,MulG(loc).x_mean))
        %      disp(sprintf('Local Var  = %5.3f (Lookup Var  = %5.3f)',dv,MulG(loc).x_var))
        
        %      pause(1)
        
        if dv<0.00001;
          d_draw=de;
        else
          
          try
            % draw from local cpdf (use lookup table
            r=rand(1);
            d_draw=interp1(p,MulG(loc).x_cpdf,r);
            
            if isnan(d_draw)
              if r<0.5
                d_draw=min(MulG(loc).x_cpdf)
              else
                d_draw=min(MulG(loc).x_cpdf)
              end
            end
            
          catch
            disp(sprintf('Some trouble de=%4.2f dv=%4.2f',de,dv))
            keyboard
            d_draw=0;
          end
        end
        
        if isnan(d_draw)
          %d_draw=norminv(rand(1),de,dv);
          disp(sprintf('Some NAN trouble de=%4.2f dv=%4.2f',de,dv))
        end      
        
        pos_known=[pos_known;pos_est(cpos,:)];
        val_known=[val_known;d_draw 0];
        
        
        % save simulated data for output
        simdata(cpos,isim)=d_draw;

        whos *known*
        
        
      end % loop over node
    
    
  end % loop over simulations
  
  
  
  