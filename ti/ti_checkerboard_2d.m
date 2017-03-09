% ti_checkerboard_2d: 2D checkerboard TI
%  
%   TI=ti_checkerboard_2d(W_CHECK,N)
%     W_CHECK: Width of each white/black square
%     N: Number if pixels in each direction
%
function TI=ti_checkerboard_2d(W_CHECK,N)
if nargin<1, W_CHECK=4; end
if nargin<2, N=200;end

N_CHECK=ceil(N/W_CHECK);
TI = checkerboard(W_CHECK,ceil(N_CHECK/2));
TI=double(TI<0.5);
    