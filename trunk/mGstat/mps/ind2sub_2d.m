% ind2sub_2d : Very fast replacement for ind2sub for 2D matrices
% From http://tipstrickshowtos.blogspot.dk/2011/09/fast-replacement-for-ind2sub.html
% See also: ind2sub
%
function [r,c] = ind2sub_2d(nrows_ncols,idx);
r = rem(idx-1,nrows_ncols(1))+1;
c = (idx-r)/nrows_ncols(1) + 1;
