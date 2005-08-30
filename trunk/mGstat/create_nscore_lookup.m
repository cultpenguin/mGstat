function [MulG,p]=create_nscore_lookup(target_hist)
  t_max=max(target_hist);
  t_min=min(target_hist);
  score_max=t_max+.1*(t_max-t_min)
  score_min=t_min-.1*(t_max-t_min)
  [d_nscore,o_nscore]=nscore(target_hist,.5,.5,score_min,score_max);

  ngm=170;
  ngv=170;
  ng=300;

  gmean_arr=linspace(-3.5,3.5,ngm);
  % gvar_arr=exp(linspace(-3,2,ngv));
  gvar_arr=[1:1:ng]./ng;
  
  p= (1/ngv).*[1:1:ngv]-1/(2*ngv) % SELECT QUANTILES TO CALCULATE
                                  %if isfield(options,'MulG')==0,
                                  % ONLY CALCUALTE MulG IF NOT ALLREADY SET...
  %end
  
  for i=1:length(gmean_arr);
    progress_txt([i],[length(gmean_arr)],'Lookup Local CPDF')
    for j=1:length(gvar_arr);
      % progress_txt([i j],[length(gmean_arr) length(gvar_arr)],'mean','var')
      
      % GET QUANTILES IN GAUSS SPACE
      x_gauss=norminv(p,gmean_arr(i),sqrt(gvar_arr(j)));
      % BACK TRANSFORM QUANTILES
      x_inscore=inscore(x_gauss,o_nscore);
      
      % NEW TRY
      MulG(i,j).x_cpdf=x_inscore;
      % Calculate c_mean from Gaussian_Mean=0, quantile 0.5
      % Only valid for symmtric target histograms.!
      %MulG(i,j).x_mean1=x_inscore(round(length(p)/2));
      % to get variance we have to simulate the back transformed
      % distribition
      d=inscore(gmean_arr(i)+randn(1,ng).*(gvar_arr(j)),o_nscore);
      MulG(i,j).x_var=nanvar(d);
      MulG(i,j).x_mean=nanmean(d);
      
    end
  end
  
  
  k=0;
  % doPlot
  doPlot=1;
  if doPlot==1
    for j=1:3,
      for i=1:3,
        k=k+1;

        figure(1);
        subplot(3,3,k);
        plot( MulG(i,j).x_cpdf , p )
        ax=axis;axis([ax(1) ax(2) 0 1])
        text(.1,.9,sprintf('Mean=%5.3f', MulG(i,j).x_mean))
        text(.1,.80,sprintf('std =%5.3f', sqrt(MulG(i,j).x_var)))
        drawnow
      
        figure(2);
        subplot(3,3,k);
        d_draw=interp1(p,MulG(i,j).x_cpdf,rand(1,10000));
        hist(d_draw,40);
        ax=axis;%axis([0-6 6 ax(3) ax(4)])
        text(.1,.9,sprintf('Mean=%5.2f', MulG(i,j).x_mean),'Units','Normalized')
        text(.1,.80,sprintf('std =%5.2f', sqrt(MulG(i,j).x_var)),'Units','Normalized')
      
        title(sprintf('gmean=%5.2f gvar=%5.2f',gmean_arr(i),gvar_arr(j)))
        
      end
    end    
    figure(3)
    scatter([MulG.x_mean],[MulG.x_var],30,[MulG.x_var],'filled');
    
    xlabel('mean');
    ylabel('var');
  end
  