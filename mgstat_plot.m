% mgstat_plot
%
% CALL :  mgstat_plot(G,MarkerSize,cax);
%
function mgstat_plot(G,MarkerSize,cax);
  
  if nargin<1,
    help mgstat_plot;
    return;
  end
  if nargin==1,
    MarkerSize=1;
  end

  if isstruct(G)==1,
    gstat_filename=write_gstat_par(G);
    [p,v,c,mask,G]=mgstat(G);
  else
    gstat_filename=G;
    [p,v,c,mask,G]=mgstat(G);      
  end

%   if ~isstruct(G)
%     [p,v,c,mask,G]=mgstat(G);
%   else
%     parfile=write_gstat_par(G);
%     [p,v,c,mask,G]=mgstat(parfile);
%   end
  
  if isfield(G,'predictions')
  for i=1:length(G.predictions);
    figure(i)
    
    datafile='';
    dataname=G.predictions{i}.data;
    for id=1:length(G.data)
      if strcmp(G.data{id}.data,G.predictions{i}.data)==1,
        datafile=G.data{id}.file;
      end
    end
    
    [data,header]=read_eas(datafile);
    mgstat_convert(G.predictions{i}.file);

    
    % [pred{i},x,y,dx,nanval]=read_gstat_ascii([G.predictions{i}.file,'.ascii']);
    [pred{i},x,y,dx,nanval]=read_arcinfo_ascii([G.predictions{i}.file,'.ascii']);
  
   
    ix=G.data{i}.x; iy=G.data{i}.y; iv=G.data{i}.v;

    if isfield(G.data{i},'log'),
      pred{i}=exp(pred{i});
    end

    imagesc(x,y,pred{i});axis image
    if nargin==3, 
      caxis(cax); 
    else
      cax=[min(data(:,iv)) max(data(:,iv))];caxis(cax);
    end
    if MarkerSize>0
      hold on
      cplot(data(:,ix),data(:,iy),data(:,iv),cax,MarkerSize);
      hold off
    end

    title(sprintf('%s - %s',G.mgstat.parfile,G.predictions{i}.data),'interpreter','none');
    
    set(findobj('type','axes'),'FontSize',7)

  end
  else
    mgstat_verbose(sprintf('%s : No prediction data :/',mfilename),1);
  end
