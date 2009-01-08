% dssim : Direct Sequential SIMulation 
%         using histogram reproduction (Deutsch 2000, Oz et. al. 2003)
%
% Call :
% [simdata,options]=dssim(pos_known,val_known,pos_est,V,options);
%

function [simdata,options]=dssim(pos_known,val_known,pos_est,V,options);

  rand('seed',1);
  
  pos_known_orig=pos_known;
  val_known_orig=val_known;
  
%  n_known=size(pos_known,1);
%  n_pos_est=size(pos_est,1);

  
  npos_known=size(pos_known,1);
  npos_est=size(pos_est,1);
  

  
  % ALLOCATE SPACE
  pos_known=zeros(npos_known+npos_est,size(pos_known_orig,2));
  val_known=zeros(npos_known+npos_est,size(val_known_orig,2));
  
  pos_known(1:npos_known,:)=pos_known_orig;
  val_known(1:npos_known,:)=val_known_orig;
  
  
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
        if t>.3
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
        
        % Update covariance from lookup table
        %options.d2d = options.CovMat([1:npos_known,npos_known+rpath(1:(i-1))'],[1:npos_known,npos_known+rpath(1:(i-1))']);    
        if isfield(options,'d2d');        options=rmfield(options,'d2d');;end
        options.d2u = options.CovMat([1:npos_known,npos_known+rpath(1:(i-1))'],npos_known+cpos);    

        
        % calculate local cpdf (kriging)
        pos_known_krig=pos_known(1:(npos_known+(i-1)),:);
        val_known_krig=val_known(1:(npos_known+(i-1)),:);
        [dm,dv,l,K,k]=krig(pos_known_krig,val_known_krig,pos_est(cpos,:),V,options);
        
        % find close cond hist fro mllokup table
        p_mean=(x_mean-dm);
        p_var=(x_var-dv);
        dis=([p_mean.^2 + p_var.^2]);
        loc=find(dis==min(dis));
                        
        % DRAW FROM LOOKED UP HISTOGRAM
        %
        %      disp(sprintf('Local Mean = %5.3f (Lookup Mean = %5.3f)',dm,MulG(loc).x_mean))
        %      disp(sprintf('Local Var  = %5.3f (Lookup Var  = %5.3f)',dv,MulG(loc).x_var))
        
        %      pause(1)
        
        if dv<0.00001;
          d_draw=dm;
        else
          
          try
            % draw from local cpdf (use lookup table
            r=rand(1);
            %d_draw=interp1(p,MulG(loc).x_cpdf,r);
            d_draw=MulG(loc).x_cpdf(floor(r*length(MulG(loc).x_cpdf))+1);

            
            Fmean(i)=MulG(loc).x_mean;
            Fstd(i)=sqrt(MulG(loc).x_var);
            Kmean(i)=dm;
            Kstd(i)=sqrt(dv);

            % d_draw = (Kstd(i)/Fstd(i))*d_draw + (Kmean(i)-Fmean(i));
            
            if isnan(d_draw)
              if r<0.5
                d_draw=min(MulG(loc).x_cpdf)
              else
                d_draw=min(MulG(loc).x_cpdf)
              end
            end
            
          catch
            disp(sprintf('Some trouble dm=%4.2f dv=%4.2f',dm,dv))
            keyboard
            %d_draw=0;
          end
        end
        
        if isnan(d_draw)
          %d_draw=norminv(rand(1),dm,dv);
          disp(sprintf('Some NAN trouble dm=%4.2f dv=%4.2f',dm,dv))
        end      
        
        pos_known(npos_known+i,:)=pos_est(cpos,:);
        val_known(npos_known+i,:)=[d_draw 0];
                
        
        % save simulated data for output
        simdata(cpos,isim)=d_draw;

        
      end % loop over node
      
      
    end % loop over simulations
    

    subplot(2,1,1)
    plot(Kstd,Fstd,'.');xlabel('Kstd');ylabel('Fstd')
    subplot(2,1,2)
    plot(Kmean,Fmean,'.');xlabel('Kmean');ylabel('Fmean')
    
  
  keyboard