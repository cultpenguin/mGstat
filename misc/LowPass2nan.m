% LowPass2nan : 2d low passfilter if data containing NaN's
% 
%[data2,filterdata,kx,kz]=LowPass2nan(data,cutoff,dx,n,pdata)
%
%
function [data2,data,kx,kz]=LowPass2nan(data,cutoff,dx,n,pdata)

if nargin==0,
    load clown;
    data=X;
    dx=0.004;
    cutoff=10;
    n=7;
    pdata=1
end

if nargin==1;
	disp('Cutoff frequency must be supplied')
	break
end

if nargin==2;
    dx=1;
    n=7;
        pdata=0;
end


if nargin==3;
    n=7;
        pdata=0;
end


%if exist('pdata')==0;
%    pdata=1;
%end

[nz,nx]=size(data);
[xx,zz]=meshgrid(1:1:nx,1:1:nz);

%if(isnan(data(1,1))), data(1,1)=nanmean(data(:));end
%if(isnan(data(nz,1))), data(nz,1)=nanmean(data(:));end
%if(isnan(data(1,nx))), data(1,nx)=nanmean(data(:));end
%if(isnan(data(nz,nx))), data(nz,nx)=nanmean(data(:));end

nans=find(isnan(data)==1);
reals=find(isnan(data)==0);

X=xx(reals);
Z=zz(reals);
D=data(reals);

XI=xx(nans);
ZI=zz(nans);

[DI]=griddata(X,Z,D,XI,ZI,'nearest');
data(nans)=DI;

%data2=data;
[data2,filterdata,kx,kz]=LowPass2(data,cutoff,dx,n,pdata);
data2(nans)=NaN;