for i=1:17,
  if i<10
    filename=['ex0',num2str(i),'.cmd'];
  else
    filename=['ex',num2str(i),'.cmd'];
  end
  try
    read_gstat_par(filename);
    disp(sprintf('READING PARFILE %d success',i))
  catch
    disp(sprintf('READING PARFILE %d FAILED',i))
  end
  
  if i>2
    try
      [p,v,c,mask,G]=mgstat(filename);
      
      disp(sprintf('EXECUTION of %d success',i))
    catch
      disp(sprintf('EXECUTION of %d FAILED',i))
    end

    try
      nrows=( (length(p)>0)+(length(v)>0)+(length(c)>0));
      
      figure(i),
      % PREDS;
      for is=1:length(p); 
        subplot(nrows,length(p),is);
        imagesc(p{is});axis image
        title(sprintf('pred %d',is));
        colorbar
      end 
      % VAR;
      for is=1:length(v); 
        subplot(nrows,length(v),is+length(v));
        imagesc(v{is});axis image
        title(sprintf('var %d',is))
        colorbar
      end 
       % COVAR;
      for is=1:length(c); 
        subplot(nrows,length(c),is+2*length(c));
        imagesc(c{is});axis image
        title(sprintf('covar %d',is))
        colorbar
      end 
      suptitle(filename)
      set(findobj('type','axes'),'FontSize',7)

      % fignan;eval(sprintf('print -dpng -r150 ex%d.png',i));close
      
    catch
      disp(sprintf('PLOTTING of %d failed',i))
    end
  end

  
end