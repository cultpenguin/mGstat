% mps_template: creates template for use with snesim;
%
% Call 
%   [template]=mps_template(n_max,n_dim,do_plot);
%
%   n_max=16; % max 16 conditioning data (def=4);
%   n_dim=2; % 1D/2D/3D (def=2)
%   do_plot=1; % Plots some figures of the template (def=0)
%   template=mps_template(n_max,n_dim,do_plot);
%
%   template [n_max,5]:
%       col1: index
%       col2: distance to center
%       col3: ix index x-location reltive to center
%       col4: iy index y-location reltive to center
%       col5: iz index z-location reltive to center
%
% 
function [template]=mps_template(n_max,n_dim,do_plot);

if nargin<1, n_max=4;end
if nargin<2, n_dim=2;end
if nargin<3, do_plot=0;end

lim=ceil((n_max/2).^(1/n_dim));
if n_dim==1
    x=-lim:1:lim;
    y=0;
    z=0;
elseif n_dim==2
    x=-lim:1:lim;
    y=-lim:1:lim;
    z=0;
elseif n_dim==3
    x=-lim:1:lim;
    y=-lim:1:lim;
    z=-lim:1:lim;  
end
[xx,yy,zz]=meshgrid(x,y,z);
ix_c=lim+1;
iy_c=lim+1;

% compute distance and sort indexes by distance to center note
d=sqrt((xx.^2)+(yy).^2+(zz).^2);
sort_data=sortrows([d(:) xx(:) yy(:) zz(:)],1);

% return the teamplate
% Remove the distance column and return as template
template=[sort_data(2:(n_max+1),2:end)];

if do_plot==1;
    
  
  s_size=[1:size(template,1)]./size(template,1);
  s_size=fliplr(124*(s_size/2));
  scatter3(template(:,3),template(:,4),template(:,5),s_size,'filled')
  hold on
  scatter3(0,0,0,124,10,'filled')
  hold off
  
  
  if n_dim==2;
  
    d_index=d.*NaN;
    
    subplot(1,2,1);
    imagematrix(d);
    hold on
    for i=1:n_max
        d_index(iy_c+template(i,4),ix_c+template(i,3))=i;
        t=text(ix_c+template(i,3),iy_c+template(i,4),num2str(i));
        set(t,'HorizontalAlignment','center')
        set(t,'VerticalAlignment','middle')
        
    end
    hold off
    set(gca,'ydir','normal')
    
    subplot(1,2,2);
    imagematrix(d_index);
    set(gca,'ydir','normal')
    caxis([-1,n_max])
  end
end