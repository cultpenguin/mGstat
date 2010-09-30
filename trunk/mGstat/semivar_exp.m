% semivar_exp : Calculate experimental variogram
%
%[gamma,h,ang_center,gamma_cloud,h_cloud]=semivar_exp(pos,val,nbin,nbinang)
%
% pos : [ndata,ndims]
% val : [ndata,ndata_types]
%
% nbin : [integer] number of bins on distance anxes
%        [array] if specified as an array, this is used.
%
% nbinang : [integer] number of arrays between 0/180 degrees (def=1)
%           [array] array of angles.
%
% Example : load jura data
%   dwd=[mgstat_dir,filesep,'examples',filesep,'data',filesep,'jura',filesep];
%   [p,pHeader]=read_eas([dwd,'prediction.dat']);
%   idata=6;dval=pHeader{idata};
%   pos=[p(:,1) p(:,2)];
%   val=p(:,idata);
%   figure;scatter(pos(:,1),pos(:,2),10,val(:,1),'filled');
%     colorbar;title(dval);xlabel('X');ylabel('Y');axis image;
%
% Example isotrop:
%   [garr,hc]=semivar_exp(pos,val);
%   plot(hc,garr);
%   xlabel('Distance (m)');ylabel('semivariance');title(dval)
%
% Exmple directional
%   [garr,hc,hangc,gamma,h]=semivar_exp(pos,val,20,4);
%   plot(hc,garr);
%   legend(num2str(180*hangc'./pi))
%   xlabel('Distance (m)');ylabel('semivariance');title(dval)
%
%
%

% TMH/2005-2009
%
%
function [garr,hc,hangc,gamma,h]=semivar_exp(pos,val,nbin,nbinang)


ndata=size(pos,1);
ndims=size(pos,2);

if ndims==1;
    % THIS SHOULD BE CHECKED FOR BUGS
    pos=[pos 0.*pos];
    ndims=2;
end

ndata_types=size(val,2);

% First calculate the 'distance' vector
nh=sum(1:1:(ndata-1)); % Find number of pairs of data

h=zeros(nh,1);
gamma=zeros(nh,ndata_types);
vang=zeros(nh,1);

i=0;
for i1=1:(ndata-1)
    for i2=(i1+1):ndata
        i=i+1;
        if ((i/100000)==round(i/100000))
            disp(sprintf('semivar_exp : i=%d/%d',i,nh))
        end
        
        p1=[pos(i1,:)];
        p2=[pos(i2,:)];
        %dp(i,:)=p1-p2;
        h(i)=sqrt( (p1-p2)*(p1-p2)' );
        gamma(i,:)=0.5*(val(i1,:)-val(i2,:)).^2;
        % ANGLE
        pp=p1-p2;
        % WORKS ONLY FOR 2D
        if pp(1)==0
            vang(i)=pi/2;
        else
            if (pp(1)>0);
                
            end
            vang(i)=atan(pp(1)./pp(2));
        end
        
    end
end
ii=find(vang<0);vang(ii)=vang(ii)+pi;
vang=180*vang/pi;

%%%%%%%%%%%%%%%%%%%%%%%%%%
% BIN INTO ARRAY BINS
if exist('nbin')==0
    nbin=10;
else
    if length(nbin)~=1
        h_arr=nbin;
        nbin=length(h_arr)-1;
    end
end

if exist('h_arr')==0
    h_arr=linspace(0,max(h).*.3,nbin+1);
end
hc=(h_arr(1:nbin)+h_arr(2:nbin+1))./2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BIN INTO ANGLE BINS

if exist('nbinang')==0
    nbinang=1;
else
    if length(nbinang)~=1
        ang_array=nbinang;
        nbinang=length(nbinang)-1;
    end
end
if exist('ang_array')==0
    ang_array=linspace(0,180,nbinang+1);
end
hangc=(ang_array(1:nbinang)+ang_array(2:nbinang+1))./2;

clear garr
for j=1:nbinang
    disp(sprintf('semivar_exp binning: i=%d/%d',i,nbinang))
    for i=1:nbin
  
        f=find(h>=h_arr(i) & h<h_arr(i+1) & vang>=ang_array(j) & vang<ang_array(j+1));
        if (sum(gamma(f,:))==0)
            garr(i,j,:)=NaN;
        else
            garr(i,j,:)=mean(gamma(f,:));
            
        end
    end
end
