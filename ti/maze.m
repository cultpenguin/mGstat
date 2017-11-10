% maze : 2D [810x810] training image
% from From Dirk-Jan Kroon's fast marching toolbox
function d=maze(tight);
d=load('maze.mat');
d=d.maze;

if nargin<1, tight=1;end
if tight==1;
    % remove boundary
    d=d(7:804,8:805);
end
