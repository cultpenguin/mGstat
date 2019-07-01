% ti_checkerboard_2d: 2D checkerboard TI
%  
%   TI=ti_checkerboard_2d(w,N,ncat)
%     w: width of checkerboard
%     N: Number if pixels in each direction
%     ncat: Number of categories
%
%
%   examples:
%      TI = ti_checkerboard_2d(2);
%      TI = ti_checkerboard_2d(3,10);
%      TI = ti_checkerboard_2d([3 3],[30,40],3);
%
function TI=ti_checkerboard_2d(w,N,ncat)
if nargin<1, w=2; end
if nargin<2, N=w*20;end
if nargin<3, ncat=2;end
    
if length(w)==1;
    wx=w;
    wy=w;
else
    wx=w(1);
    wy=w(2);
end
if length(N)==1;
    nx_ti=N;
    ny_ti=N;
else
    nx_ti=N(1);
    ny_ti=N(2);
end
x_ti=1:1:nx_ti;
y_ti=1:1:ny_ti;
[xx,yy]=meshgrid(x_ti,y_ti);
ixx=mod(ceil(xx/wx),ncat);
iyy=mod(ceil(yy/wy),ncat);
TI=mod(iyy+ixx,ncat);



    