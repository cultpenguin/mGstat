% mgstat_krig2d : 2D kriging
%
% [pred,pred_var,x_arr,y_arr,G]=mgstat_krig2d(x,y,val,V,x_arr,y_arr)
%
% [REQUIRED]
%
% x   [1:nd] = x-positions
% y   [1:nd] = y-positions
% val [1:nd] = Values to be kriged
%
% [OPTIONAL]xs
%
% V : Variogram. Two formats :
%     V{}    : Matlab structure (mGstat format)
%     V[char]: '5 Nug(10) + 4 Sph(8)' (gstat format);
%
% x_arr : [1:ndata] : X pos to be kriged 
% y_arr : [1:ndata] : Y pos to be kriged 
%
%
% CALL WITHOUT ARGUMENTS FOR A DEMO !
%
% (C) tmh/2004
%
%
function [pred,pred_var,x_arr,y_arr,G]=mgstat_krig2d(x,y,val,V,x_arr,y_arr)

  
  
  if nargin==2
    mgstat_verbose(sprintf('%s : You need at least 3 input raguments',mfilename));
    help mgstat_krig2d;
    return;
  end
    
  if (((nargin<4)&(nargin~=0))),
    d=sqrt(x.^2+y.^2);e=max(d)./10;
    V=sprintf('0.3 Nug(0) + 1 Sph(%6.2f)',e);
    V=semivar_optim([x y],val,linspace(0,nanmean(d),20),V,1);
    figure,
  end
  
  if nargin>4
    if isempty(V)
      d=sqrt(x.^2+y.^2);e=max(d)./10;
      V=sprintf('0.3 Nug(0) + 1 Sph(%6.2f)',e);
      V=semivar_optim([x y],val,linspace(0,nanmean(d),20),V,1);
      figure,
    end
  end
  
  if ((nargin<5)&(nargin~=0))
    dx=round(10*(max(x)-min(x))/100)./10;
    if dx==0,       
      dx=1; 
    end
    %x_arr=[.9*min(x):dx:max(x)*1.1];
    %y_arr=[.9*min(y):dx:max(y)*1.1];
    
    % THE FOLLOWING LINES SET NX=100
    nx=15;
    wx=(max(x)-min(x))*.1;
    x_arr=linspace(min(x)-wx,max(x)+wx,nx);
    dx=x_arr(2)-x_arr(1);
    y_arr=[min(y)-wx:dx:max(y)+wx];
  end
  
  if nargin==0,
    %ntestdata=round(10+20*rand);
    % SHOW DEMO
    mgstat_verbose(sprintf('%s : No Input Pars Given -> Running demo;',mfilename),1)
    rseed=4;  dx=1;dy=dx;  ax=10;ay=ax;  nx=45;ny=100;  ix=nx*dx;  iy=ny*dy;
    pop=1;    med=1;  nu=.7;
    mgstat_verbose(sprintf('%s : Calculating random field.',mfilename),1)
    data=vonk2d(rseed,dx,dy,ax,ay,ix,iy,pop,med,nu);

    x_arr=[1:1:nx]*dx;    y_arr=[1:1:ny]*dy;

    ntestdata=42;
    x=round(rand(ntestdata,1)*(ix-1)+1);
    y=round(rand(ntestdata,1)*(iy-1)+1);
    [xx,yy]=meshgrid(x_arr,y_arr);
    val=interp2(xx,yy,data,x,y);
        
    %V=('0.3 Nug(0) + 1 Gau(100)');
    V=('7.6 Lin(62)');
    % V=semivar_optim([x y],val,linspace(0,130,20),V,1);
    figure;

  end

  if (size(x,2)~=1), x=x(:); end
  if (size(y,2)~=1), y=y(:); end
  if (size(val,2)~=1), val=val(:); end
  
  x=x(:); y=y(:); val=val(:);
  
  nx=length(x_arr);ny=length(y_arr);
  
  % Obs FILE
  header{1}='Xlocation, []';
  header{2}='Ylocation, []';
  header{3}='Observation, []';
  eas_file='krig2d_obs.eas';
  write_eas(eas_file,[x y val],header);
  
  %%% G
  
  % mgstat
  parfile='krig2d.cmd';
  G.mgstat.parfile=parfile;
  
  % Data 
  G.data{1}.data='val';
  G.data{1}.file=eas_file;
  G.data{1}.x=1;
  G.data{1}.y=2;
  G.data{1}.v=3;
  %G.data{1}.min=min(val);
  %G.data{1}.max=max(val);
  %% NEXT LINE FOR STABILITY ONLY !!!
  %G.data{1}.radius=5*max(sqrt((x-nanmean(x)).^2+(y-nanmean(y)).^2));
  
  
  
  % variogram
  G.variogram{1}.data=G.data{1}.data;
  if isstruct(V)
    G.variogram{1}.V=V;
  else
    G.variogram{1}.V=deformat_variogram(V);
  end
  
  % mask
  mask=zeros(ny,nx).*0+1;
  mask_file='krig2d_mask.ascii';
  % write_gstat_ascii(mask_file,mask,x_arr,y_arr,-9999);
  write_arcinfo_ascii(mask_file,mask,x_arr,y_arr,-9999);
  G.mask{1}.file=mask_file;

  % Predictions
  pred_file='krig2d_pred';
  G.predictions{1}.data=G.data{1}.data;
  G.predictions{1}.file=pred_file;
  % Variances
  var_file='krig2d_var';
  G.variances{1}.data=G.data{1}.data;
  G.variances{1}.file=var_file;
  
  %write_gstat_par(G);
  %[pred,pred_var,pred_covar,mask,G]=mgstat(G.mgstat.parfile);

  mgstat_verbose(sprintf('%s : Starting gstat ...',mfilename),1);
  [pred,pred_var]=mgstat(G);
  pred=pred{1};
  pred_var=pred_var{1};
  
  doPlot=1;
  if doPlot==1,

    if nargin==0,
      if nx<ny,subplot(1,3,1),else,subplot(3,1,1);end
      
      imagesc(data);axis image
      %contourf(data,linspace(min(val),max(val),10));axis image
      caxis([min(val) max(val)]);
      title('Orig Data');colorbar

    end

    
    
    if nargin==0,
      if nx<ny,subplot(1,3,2),else,subplot(3,1,2);end
    else
      if nx<ny,subplot(1,2,1),else,subplot(2,1,1);end
    end
    imagesc(x_arr,y_arr,pred);axis image
    %contourf(x_arr,y_arr,pred,linspace(min(val),max(val),10));axis image    
    caxis([min(val) max(val)]);cax=caxis;
    hold on;cplot(x,y,val,[],29);hold off;
    title('Predictions');colorbar
    axis image
    
    if nargin==0
      if nx<ny,subplot(1,3,3),else,subplot(3,1,3);end
    else
      if nx<ny,subplot(1,2,2),else,subplot(2,1,2);end
    end
    imagesc(x_arr,y_arr,pred_var)
    hold on;plot(x,y,'k.','MarkerSize',10);hold off;
    title('Variances');colorbar
    axis image

    set(findobj('type','axes'),'FontSize',7)

    var=format_variogram(G.variogram{1}.V);
    
    suptitle(sprintf('Simple 2D Kriging : %s',var));

  end