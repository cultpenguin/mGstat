% find_row_array : find row vector in matrix 
%
% 
% 
% [Nd,Narr] marr
% [1,Narr]
%
% example
%   marr = [1 2 3 ; 2 3 1 ; 2 1 1 ; 0 0 0 ; 1 2 1 ; 2 3 1];
%   arr = [ 2 3 1 ];
%   ir = find_row_array(marr,arr)
%      ir=
%           2
%           6
%
function ir=find_row_array(marr,m);

mmul=repmat(m,size(marr,1),1);

ir = find(sum(abs(mmul-marr),2)<1e-19);


