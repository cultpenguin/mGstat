% eikonal_raylength : Computes the raylength from S to R using the eikonal equaiton
%
% Call:
%   raylength=eikonal_raylength(x,y,v,S,R,tS,doPlot)
%
function [raylength]=eikonal_raylength(x,y,v,S,R,tS,doPlot)

if nargin<7
    doPlot=0;
end

% FIND DX
try dx=x(2)-x(1);catch;dx=x(1);end
try dy=y(2)-y(1);catch;dy=y(1);end

%% COMPUTE tS if ot isnot allready set
if nargin<6
    tS=fast_fd_2d(x,y,v,S);
end

%% NOW FIND FIRST ARRIVAL AND RAYLENGTH
str_options = [.1 20000];
[xx,yy]=meshgrid(x,y);
[U,V]=gradient(tS);
start_point=R;
raypath = stream2(xx,yy,-U,-V,start_point(1),start_point(2),str_options);

try
    raypath=raypath{1};
    % GET RID OF DATA CLOSE TO SOURCE (DIST <DX)
    r2=raypath;r2(:,1)=r2(:,1)-S(1);r2(:,2)=r2(:,2)-S(2);
catch
    raylength=NaN;
    return;
end
dd=min([dx dy]);
distS=sqrt(r2(:,1).^2+r2(:,2).^2);
ClosePoints=find(distS<dd/10);
%igood=find(distS>dx/10);
if isempty(ClosePoints)
    igood=1:1:length(distS);
else
    igood=1:1:ClosePoints(1);
end
raypath=[raypath(igood,:);S(1:2)];

raylength=sum(sqrt(diff(raypath(:,1)).^2+diff(raypath(:,2)).^2));

%% PLOT
if doPlot==1;
    subplot(3,2,3);imagesc(x,y,U);axis image
    subplot(3,2,4);imagesc(x,y,V);axis image
    subplot(3,1,1);imagesc(x,y,tS);axis image
    subplot(3,1,3);imagesc(x,y,v);axis image;
    hold on
    plot(raypath(:,1),raypath(:,2),'k*');
    hold off
end
