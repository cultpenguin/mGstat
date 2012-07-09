% csemivar_exp : Calculate experimental cross semivariogram 
%
%[hc,garr,h,gamma,hangc,head,tail]=semivar_exp(pos1,val1,pos2,val2,nbin,nbinang)
%  
% pos1 : [ndata,ndims] : attribute 1
% val1 : [ndata,1]     : attribute 1
% pos2 : [ndata,ndims] : attribute 2
% val2 : [ndata,1]       attribute 2
%
% nbin : [integer] number of bins on distance anxes
%        [array] if specified as an array, this is used.
%  
% nbinang : [integer] number of arrays between 0/180 degrees
%                     (default 1)
% Example isotrop: 
%   [hc,garr]=semivar_exp(pos1,val1,pos2,val2);
%   plot(garr,hc);
%
% Example directional [0,45,90,135,180]: 
%   [hc,garr,h,gamma,hangc]=semivar_exp(pos1,val1,pos2,val2,20,4);
%   plot(garr,hc);
%   legend(num2str(hangc'))
% 
%
% TMH/2005
%
function [hc,garr,h,gamma,hangc,z_head,z_tail]=semivar_exp(pos,val1,val2,nbin,nbinang)
  
  
ndata=size(pos,1);
ndims=size(pos,2);


% SCALE ATTRIBUTES BY VARIANCE
%val1=(val1-mean(val1))./var(val1);
%val2=(val2-mean(val2))./var(val2);
% First calculate the 'distance' vector
nh=sum(1:1:(ndata-1));

h=zeros(nh,1);
z_head=zeros(nh,1);
z_tail=zeros(nh,1);
gamma=zeros(nh,1);
vang=zeros(nh,1);

i=0;
for i1=1:(ndata-1)
for i2=(i1+1):ndata
  i=i+1;
  if ((i/20000)==round(i/20000))
    disp(sprintf('csemivar_exp : i=%d/%d',i,nh))
  end

  p1=[pos(i1,:)];
  p2=[pos(i2,:)];
  h(i)=sqrt( (p1-p2)*(p1-p2)' ); 
  z_head(i,:)=val1(i1,:);
  z_tail(i,:)=val2(i2,:);
  gamma(i,:)=0.5* (val1(i1,:)-val1(i2,:))*(val2(i1,:)-val2(i2,:));
  % ANGLE
  aa=sqrt(sum(p1.^2));
  bb=sqrt(sum(p2.^2));
  ab=(p1(:)'*p2(:));

  pp=p1-p2;

  % WORKS ONLY FOR 2D
  if pp(1)==0
    cang(i)=pi/2;
  else
%    vang(i)=atan(pp(1)./pp(2));
    vang(i)=atan(pp(2)./pp(1));
  end

end
end
vang=vang+pi/2;

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
    nbinang=length(nbinang)-1
  end
end
if exist('ang_array')==0 
  ang_array=linspace(0,pi,nbinang+1);
end
hangc=(ang_array(1:nbinang)+ang_array(2:nbinang+1))./2;


clear garr
for i=1:nbin
  for j=1:nbinang
  f=find(h>=h_arr(i) & h<h_arr(i+1) & vang>=ang_array(j) & vang<ang_array(j+1));

  garr(i,j,:)=mean(gamma(f,:));
  end
end

