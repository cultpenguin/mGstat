% cokrig_sk : Simple CoKriging
%
% Call :
%  function [d_est,d_var,lambda_sk,K_sk,k_sk]=cokrig_sk(pos_known,val_known,pos_est,V,val_0);
%
% TMH/2005
%

function [d_est,d_var,lambda_sk,K_sk,k_sk]=cokrig_sk(pos_known1,val_known1,pos_known2,val_known2,pos_est,V1,V2,V12,mean1,mean2);

%  if isstr(V),
%    V=deformat_variogram(V);
%  end 
%  
%  if nargin==4,
%    val_0=mean(val_known);
%  end
  
nknown1=size(pos_known1,1);
ndim1=size(pos_known1,2);
gvar1=sum([V1.par1]);

nknown2=size(pos_known2,1);
ndim2=size(pos_known2,2);
gvar2=sum([V2.par1]);

gvar12=sum([V12.par1]);

nknown12=nknown1+nknown2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data to Data matrix
K_sk=zeros(nknown12,nknown12);

% PRIMARY ATT
K11_sk=zeros(nknown1,nknown1);
for i=1:nknown1;
  for j=1:nknown1;
    d=edist(pos_known1(i,:),pos_known1(j,:));
    K11_sk(i,j)=gvar1-semivar_synth(V1,d);
  end
end

% Secondary ATT
K22_sk=zeros(nknown2,nknown2);
for i=1:nknown2;
  for j=1:nknown2;
    d=edist(pos_known2(i,:),pos_known2(j,:));
    K22_sk(i,j)=gvar2-semivar_synth(V2,d);
  end
end

% Cross data to data
K12_sk=zeros(nknown1,nknown2);
for i=1:nknown1;
  for j=1:nknown2;
    d=edist(pos_known1(i,:),pos_known2(j,:));
    K12_sk(i,j)=gvar12-semivar_synth(V12,d);
  end
end
%K12_sk=zeros(nknown1,nknown2);

K_sk=[K11_sk K12_sk;K12_sk' K22_sk];


% Data to Unknown matrix
k_sk=zeros(nknown12,1);
for i1=1:nknown1;
  d=edist(pos_known1(i1,:),pos_est);  
  k_sk(i1)=gvar1-semivar_synth(V1,d);
end
for i2=1:nknown2;
  d=edist(pos_known2(i2,:),pos_est);      
  k_sk(nknown1+i2)=gvar12-semivar_synth(V12,d);
end


lambda_sk = inv(K_sk)*k_sk;

d_est1 = (val_known1' - mean1)*lambda_sk(1:nknown1);
d_est2 = (val_known2' - mean2)*lambda_sk(nknown1+1:nknown12);


d_est=d_est1+d_est2 + mean1;
%d_est=d_est1 + mean1;


d_var = gvar1 - lambda_sk'*k_sk ;

