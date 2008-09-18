% LowPass1nan : 1d low passfilter if data containing NaN's
% 
%[data2,filterdata]=LowPass1nan(data,cutoff,dx,n,pdata)
%
%
function [data2,data]=LowPass1nan(data,cutoff,dx,n,pdata)

if nargin==0,
    load clown;
    data=X(:,1);
    dx=0.004;
    cutoff=10;
    n=7;
    pdata=1;
end

if nargin==1;
	disp('Cutoff frequency must be supplied')
	return
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



nans=find(isnan(data)==1);
reals=find(isnan(data)==0);

if isnan(data(1)), data(1)=data(reals(1)); end
if isnan(data(length(data))), data(length(data))=data(reals(length(reals))); end
nans=find(isnan(data)==1);
reals=find(isnan(data)==0);



idata=[1:1:length(data)];
data_interp=interp1(idata(reals),data(reals),idata);
save data_interp data_interp

%[data2]=LowPass1(data_interp,cutoff,dx,9,pdata);
[data2]=LowPass1(data_interp,cutoff,dx);

data2(nans)=NaN;

