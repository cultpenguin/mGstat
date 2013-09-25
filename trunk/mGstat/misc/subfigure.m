% subfigure : place figure in grid on screen
%
% call : 
%
%     subfigure(ny,nx,index)
%     subfigure(1,3,1); % One figure from top to bootom the the 1/3 leftmost
%                       % part of the screen
%
% See also: subplot
%

% TMH/2013
function subfigure(ny,nx,i)

if nargin<3, i=1;end
if nargin<2, ny=nx;end
if nargin==1
    if length(nx)==3;
        tmp=nx;
        nx=tmp(1);
        ny=tmp(2);
        i=tmp(3);
    end
end
if nargin<1, i=nx;end


x=linspace(0,1,nx+1);
y=linspace(0,1,ny+1);

wx=1/nx;
wy=1/ny;

iy=ceil(i/nx);
ix=i-(iy-1)*nx;

% START FROM BOTTOM LEFT
pos=[x(ix) y(ny+1-iy) wx wy];
% START FROM TOP LEFT (as subplot);
pos=[x(ix) y(ny+1-iy) wx wy];

set(gcf,'units','normalized','outerposition',pos); % 

