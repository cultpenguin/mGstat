% semivar_exp_gstat : Experimental semivariance using GSTAT
%
% CALL : 
%
% [gamma,hc,np,av_dist]=semivar_exp_gstat(pos,val,angle,tol,width,cutoff)
%
% IN : 
%    pos : [ndata,ndims] : location of data
%    val : [ndata,1] : data values
%    angle [1] : angle 
%    tol [1] : angle tolerance around 'angle'
%    width[1] : width of bin use to average semivariance
%    cutoff[1] : max distance for whoch to compute semivariance
%
%
%
% 'angle' and 'tol' are optional
%
% defults: angle=0;
%          tol=180
%
% OUT :
%    gamma : semivariance
%    hc : Seperation distance
%    np : Number of points for each seperation distance
%    av_dist : Average distance
%
%
%
function [gamma,hc,np,av_dist]=semivar_exp_gstat(pos,val,angle,tol,width,cutoff)
  
    
  if nargin<3
    angle=0;
  end
  
  if nargin<4
    tol=180;
  end

  
  
  file='tempSemi';
  
  write_eas([file,'.eas'],[pos val]);
  
  G.data{1}.data=file;
  G.data{1}.file=[file,'.eas'];
  G.data{1}.x=1;
  if size(pos,2)>1, G.data{1}.y=2; end
  if size(pos,2)>2, G.data{1}.z=3; end
  G.data{1}.v=size(pos,2)+1;
  G.method{1}.semivariogram='';
  G.variogram{1}.data=file;
  G.variogram{1}.file=[file,'.variogram'];
  G.set.alpha=angle;
  G.set.tol_hor=tol;
  if exist('width')==1
    G.set.width=width;
  end
  if exist('cutoff')==1
    G.set.cutoff=cutoff;
  end
  
  write_gstat_par(G,[file,'.cmd']);
  
  mgstat(G);
  
  d=read_gstat_semivar('tempSemi.variogram');
   
  av_dist=d(:,4);
  gamma=d(:,5);
  hc=(d(:,1)+d(:,2))./2;
  np=d(:,3);
  return
  
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
    
 
  
  