% semivar : calcualte semivariogram
%
% [binc,sv,svM]=semivar(loc,val,bin_array);
%
function [binc,sv,svM]=semivar(loc,val,bin_array);

  ndata=size(loc,1);  
  ndim_loc=size(loc,2);
  ndim_val=size(loc,2);

 
  ndd=0;
  for i=(ndata-1):-1:1,
    ndd=ndd+i;
  end

  
  dist_array=ones(ndd,1);
  gamma_array=ones(ndd,1);
  
  pos=1;
  for i1=1:ndata-1
    i2=[i1+1:1:ndata];
        
    dist=sqrt( (loc(i2,1)-loc(i1,1)).^2+((loc(i2,2)-loc(i1,2)).^2) );
    gamma=.5*(val(i2)-val(i1)).^2;
  

    gamma_array(pos:pos+length(i2)-1)=gamma;
    dist_array(pos:pos+length(i2)-1)=dist;

    pos=pos+length(i2);
    
    
  end
  
  if nargin==2,
    % NO BIN ARRAY DEFINED
    bin_array=linspace(0,max(dist)./2,10);
  end
  nbins=length(bin_array)-1;
  binc=(bin_array(1:nbins)+bin_array(2:nbins+1))./2;
  sv=zeros(1,nbins);
  
  for i=1:nbins
    ip=find( (dist_array>=bin_array(i))&(dist_array<bin_array(i+1)) );
  
    %if isempty(ip)
      g=gamma_array(ip);
    %else
    %  g=[];
    %end
    
    if isempty(g)
      sv(i)=NaN;
      sv2(i)=NaN;
      svM{i}=NaN;
    else
      sv(i)=mean(g);
      svM{i}=gamma_array(ip);
      sv2(i)=exp(nanmean(log(svM{i}+1e-3)));
    end
    
  end
  
  doPlot=0;
  if doPlot==1,
    [ax,h1,h2]=plotyy(binc,sv,binc,sv2) ;
    set(ax(1),'ylim',[0 1.1*max(sv)])
    set(ax(2),'ylim',[0 1.1*max(sv2)])
    
    set(get(ax(1),'Ylabel'),'String','mean')
    set(get(ax(2),'Ylabel'),'String','log-mean')
  end