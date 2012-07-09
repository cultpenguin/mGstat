% gstat_semivar_exp : Experimental semivariance using GSTAT
%
% CALL : 
%
% [gamma,hc,np,av_dist]=gstat_semivar_exp(pos,val,angle,tol,width,cutoff)
%
% IN : 
%    pos : [ndata,ndims] : location of data
%    val : [ndata,1] : data values
%    angle [1] : angle (degrees)
%    tol [1] : angle tolerance around 'angle' (degrees)
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
% EXAMPLE : 
%   % GET JURA DATA
%   dwd=[mgstat_dir,filesep,'examples',filesep,'data',filesep,'jura',filesep];
%   [p,pHeader]=read_eas([dwd,'prediction.dat']);
%   idata=6;dval=pHeader{idata};
%   pos=[p(:,1) p(:,2)];
%   val=p(:,idata);
%   figure;scatter(pos(:,1),pos(:,2),10,val(:,1),'filled');
%     colorbar;title(dval);xlabel('X');xlabel('Y');axis image;
% 
%   % ISOTROP SEMIVARIOGRAM
%   [gamma,hc]=_semivar_exp(pos,val);
%   figure;plot(hc,gamma);
%   title(dval);xlabel('Distance (m)');ylabel('Semivariance');
%
%   % ANISOTROPIC SEMIVARIOGRA
%   hang=[0 45 90];
%   tol=10; % Angle tolerance
%   clear gamma;
%   figure
%   for ih=1:length(hang);
%      [gamma(:,ih),hc]=gstat_semivar_exp(pos,val,hang(ih),tol);
%   end
%   figure;plot(hc,gamma);
%   title(dval);xlabel('Distance (m)');ylabel('Semivariance');
%   legend(num2str(hang'));
%
%   % ANISOTROPIC SEMIVARIOGRAM (2)
%   width=[0.1];
%   cutoff=[4];
%   hang=[0 45 90];
%   tol=10; % Angle tolerance
%   clear gamma;
%   for ih=1:length(hang);
%      [gamma,hc]=gstat_semivar_exp(pos,val,hang(ih),tol,width,cutoff);
%      p(ih)=plot(hc,gamma);hold on
%      if ih==1, set(p(ih),'color',[0 0 0]);end
%      if ih==2, set(p(ih),'color',[0 1 0]);end
%      if ih==3, set(p(ih),'color',[0 0 1]);end
%   end
%   hold off
%   title(dval);xlabel('Distance (m)');ylabel('Semivariance');
%   legend(num2str(hang'));
%
function [gamma,hc,np,av_dist]=gstat_semivar_exp(pos,val,angle,tol,width,cutoff)
  
    
  if nargin<3
    angle=0;
  end
  
  if nargin<4
    tol=180;
  end

  %% check for nan
  inan=find(isnan(sum(pos')')|isnan(val));
  if ~isempty(inan)
      igood=find(~isnan(sum(pos')')&~isnan(val));
      pos=pos(igood,:);
      val=val(igood);
  end

  
  f{1}='tempSemi.variogram';
  f{2}='tempSemi.eas';
  f{3}='tempSemi.cmd';
  f{4}='gstat.cmd';
  for i=1:length(f);
      file=[pwd,filesep,f{i}];
      if exist(file)
          delete(file)
      end
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
  % G.set.mv='-1'; % SET THE MISSING VALUE / NAN FOR GSTAT
  G.set.alpha=angle;
  G.set.tol_hor=tol;
  if exist('width')==1
    G.set.width=width;
  end
  if exist('cutoff')==1
    G.set.cutoff=cutoff;
  end
  
  write_gstat_par(G,[file,'.cmd']);

  gstat(G);

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
    
 
  
  