% gstat_plot : visualize 2D GSTAT results
%
% CALL :  gstat_plot(G,MarkerSize,cax);
%
function gstat_plot(G,MarkerSize,cax);
  
  if nargin<1,
    help gstat_plot;
    return;
  end
  if nargin==1,
    MarkerSize=20;
  end

  if isstruct(G)==1,
    gstat_filename=write_gstat_par(G);
    [p,v,c,mask,G]=gstat(G);
  else
    gstat_filename=G;
    [p,v,c,mask,G]=gstat(G);      
  end

  np=length(p);
  nv=length(v);
  
  nd=length(G.data);

  if nd==1,
    try
      dfile=G.data{1}.file;
      [d]=read_eas(dfile);
      xd=d(:,G.data{1}.x);
      yd=d(:,G.data{1}.y);
      vd=d(:,G.data{1}.v);
    catch
    end
  end

  
  [mask,x,y]=read_arcinfo_ascii(G.mask{1}.file);
  
  for i=1:length(p)
           
    if nd==np,
      try
        dfile=G.data{i}.file;
        [d]=read_eas(dfile);
        xd=d(:,G.data{i}.x);
        yd=d(:,G.data{i}.y);
        vd=d(:,G.data{i}.v);
      catch
      end
    end
    
    if nv==np
      is=(i-1)*2+1;
      subplot(np,2,is)
    else
      subplot(1,np,i);
    end
    
    % CHECK FOR LOG TRANS
    if isfield(G.data{i},'log'),
      p{i}=exp(p{i});
    end

    imagesc(x,y,p{i});axis image
    if exist('xd')==1,
      hold on
      plot(xd,yd,'w.','MarkerSize',MarkerSize);
      scatter(xd,yd,MarkerSize.*.8,vd,'filled');
      hold off
    end
    try
      title(sprintf('Mean %s',G.predictions{i}.data),'Interpreter','none')
    catch
      title('Mean')
    end
    
    if nv==np
      subplot(np,2,is+1)
      imagesc(x,y,v{i})
      try
        title(sprintf('Var %s',G.variances{i}.data))
      catch
        title('Var')
      end
      axis image
    end
    
  
  end
  
  watermark(G.mgstat.parfile);
  
  
  [p,f]=fileparts(G.mgstat.parfile);
  print('-dpng',sprintf('%s.png',f))

  
  return  

  
  if isfield(G,'predictions')
  for i=1:length(G.predictions);
    figure(i)
    
    try
      datafile='';
      dataname=G.predictions{i}.data;
      for id=1:length(G.data)
        if strcmp(G.data{id}.data,G.predictions{i}.data)==1,
          datafile=G.data{id}.file;
        end
      end
      
      [data,header]=read_eas(datafile);
    catch
      mgstat_verbose('Could not read datafile')
      data=[];header=[];
    end

    % gstat_convert(G.predictions{i}.file);        
    %[pred{i},x,y,dx,nanval]=read_arcinfo_ascii([G.predictions{i}.file,'.ascii']);
  [pred{i},x,y,dx,nanval]=read_arcinfo_ascii(G.predictions{i}.file);
  
   
    if isfield(G.data{i},'log'),
      pred{i}=exp(pred{i});
    end

    imagesc(x,y,pred{i});axis image
    if nargin==3, 
      caxis(cax); 
    else
      try
        cax=[min(data(:,iv)) max(data(:,iv))];caxis(cax);
      catch
      end
    end

    
    try
      if MarkerSize>0
        hold on
        scatter(data(:,ix),data(:,iy),MarkerSize,data(:,iv),'filled');
        hold off
      end
    catch
    end
    if isfield(G,'mgstat')
      title(sprintf('%s - %s',G.mgstat.parfile,G.predictions{i}.data),'interpreter','none');
    else
      title(sprintf('%s',G.predictions{i}.data),'interpreter','none');
    end
    set(findobj('type','axes'),'FontSize',7)
    
  end
  else
    mgstat_verbose(sprintf('%s : No prediction data :/',mfilename),1);
  end
