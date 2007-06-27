% calc_gstat_semivar
%
% Call : 
%
%    function [gamma,hc,np,av_dist]=calc_gstat_semivar(pos,val,angle,tol,cutoff,width)
%
%
function [gamma,hc,np,av_dist]=calc_gstat_semivar(pos,val,angle,tol,cutoff,width)

  if nargin<3
    angle=0;
  end
  
  if nargin<4
    tol=180;
  end

  if nargin<5
    cutoff=5;
  end

  if nargin<6
    width=cutoff./15;;
  end

%  width=str2num(sprintf('%3.1g',width));
  width=str2num(sprintf('%5.3g',width));
  file='tempSemi';
  
  write_eas([file,'.eas'],[pos val]);

  G.data{1}.data=file;
  G.data{1}.file=[file,'.eas'];
  G.data{1}.x=1;
  if size(pos,2)>1, G.data{1}.y=2; end
  if size(pos,2)>2, G.data{1}.z=3; end
  G.data{1}.v=size(pos,2)+1;
  % G.data{1}.every=10;
  G.method{1}.semivariogram='';
  G.variogram{1}.data=file;
  G.variogram{1}.file=[file,'.variogram'];
  G.set.alpha=angle;
  G.set.tol_hor=tol;
  G.set.width=width;
  G.set.cutoff=cutoff;
  G.set.format = '%12.8g';

  write_gstat_par(G,[file,'.cmd']);
  
  gstat(G);

  
  d=read_gstat_semivar('tempSemi.variogram');
  Cav_dist=d(:,4);
  Cgamma=d(:,5);
  Chc=(d(:,1)+d(:,2))./2;
  Cnp=d(:,3);
  
  dw=G.set.width./2;
  warr=[dw:2*dw:G.set.cutoff];
  nw=length(warr);
  hc=zeros(nw,1).*NaN;
  np=hc;
  av_dist=hc;
  gamma=hc;
  
  for i=1:length(Chc)
    ii=find(abs(Chc(i)-warr)<1e-9);
    gamma(ii)=Cgamma(i);
    %hc(ii)=Chc(i);
    av_dist(ii)=Cav_dist(i);
    np(ii)=Cnp(i);
  end
  hc=warr;
    
 
  
  
