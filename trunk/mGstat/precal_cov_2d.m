% precal_cov_2d : Precalculate 2D stationary covariance matrix
%
% CALL :
%   [cov]=precal_cov_2d(nx,ny,dx,dy,V,options);
%
% See also precal_cov
%
%
function [cov]=precal_cov_2d(nx,ny,dx,dy,V,options);

options.null='';
x=[1:1:nx].*dx;
y=[1:1:ny].*dy;
[xx,yy]=meshgrid(x,y);
pos1=[xx(:) yy(:)];
cov_small=precal_cov(pos1(1:ny,:),pos1,V,options);

n_est=size(pos1,1);

cov=zeros(n_est,n_est);

%% UPPER TRIANGLE
for ix=1:nx;
    iy0=(ix-1)*ny;
    ix0=(ix-1)*ny;
    %if ix==2;keyboard;keyboard;end
    x_arr=(ix0+1):n_est;
    cov((1:ny)+iy0,x_arr)=cov_small(:,1:length(x_arr));
end

%% LOWER TRIANGLE
for ix1=2:nx
    for ix2=1:ix1;
        
        ix1_0 =  (ix1-1)*ny;
        ix2_0 =  (ix2-1)*ny;
        
        x1 = (1:ny)+ix1_0;
        x2 = (1:ny)+ix2_0;
        
        cov(x1,x2)=cov(x2,x1)';
        
    end
end
        
        
