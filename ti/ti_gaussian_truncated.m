% ti_gaussian_truncated: Gaussian based trainig image
%
% Call= 
%   TI=ti_gaussian_truncated(n,r,lev,cov_typ);
%
%   TI=ti_gaussian_truncated;           % 30x30x30 TI, 2 cat
%   TI=ti_gaussian_truncated([20 20]);  % 20x20 TI , 2 cat
%   TI=ti_gaussian_truncated([20 30 20],7,[-.1 .1]); % 20x30x20 TI, 3 cat,range 7
%   TI=ti_gaussian_truncated([20 20],6,[-.1 .1],'Sph'); % 20x20 TI, 3 cat,range 26, Spherical 
%

function [TI,TIs]=ti_gaussian_truncated(n,r,lev,cov_type);

if nargin<1
    n=[30 30 30];
end

if nargin<2
    r=10;
end

if nargin<3
    lev=.1;
end

if nargin<4
    cov_type='Gau';
end


if length(r)==1
    Va=sprintf('1 %s(%g)',cov_type,r);
elseif length(r)==3;
    Va=sprintf('1 %s(%g,%g,%f)',cov_type,r(1),r(2),r(3));
elseif length(r)==6;
    Va=sprintf('1 %s(%g,%g,%f,%f,%f,%f)',cov_type,r(1),r(2),r(3),r(4),r(5),r(6));
end
    
if length(n)==1;
     [TIs]=fft_ma(1:1:n(1),Va); ;
elseif length(n)==2;
     [TIs]=fft_ma(1:1:n(1),1:1:n(2),Va); ;
elseif length(n)==3;
     [TIs]=fft_ma(1:1:n(1),1:1:n(2),1:1:n(3),Va); ;
end

% truncate
TI=0.*TIs;
for i=1:length(lev);
    TI(find(TIs>lev(i)))=i;
end
