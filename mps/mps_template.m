% mps_template: creates template for use with snesim;
%
% Call
%   [template]=mps_template(n_max,n_dim,method,do_plot);
%
% IN:
%   n_max=16; % max 16 conditioning data (def=4);
%   n_dim=2; % 1D/2D/3D (def=2)
%   method = 1; % suing n_max pints closest to center
%          = 2; % mixed point cross
%          = 3; % mixed point cross + star
%   do_plot=1; % Plots some figures of the template (def=0)
%
%
%  OUT:
%   template [n_max,3]:
%       col3: ix index x-location reltive to center
%       col4: iy index y-location reltive to center
%       col5: iz index z-location reltive to center
%
% See also mps, mps_snesim, mps_enesim
%

function [template,dist]=mps_template(n_max,n_dim,method,do_plot);

if nargin<1, n_max=4;end
if nargin<2, n_dim=2;end
if nargin<3, method=1;end
if nargin<4, do_plot=0;end

if method==1
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
    dist=sort_data(2:(n_max+1),1);
    
elseif (method==2)|(method==3)
    %template=zeros(n_dim*n_max,3);
    n_use=ceil(n_max/(n_dim*2));
    %template=[0 0 0];
    template=[];
    for i_dim=1:n_dim
        for is=[-1 1];
            ii =  [1:n_use].*is;
            t=zeros(n_use,3);
            t(:,i_dim)=ii;
            template=[template;t];
        end
    end
    
    if (method==3)
        % 2D only
        if n_dim==2;
            ii=[1:n_use];
            template2=[];
            for ix=[-1 1]
                for iy=[-1 1]
                    t=zeros(n_use,3);
                    t(:,1:n_dim)=repmat(ii(:),1,n_dim);;
                    t(:,1)=t(:,1).*ix;
                    t(:,2)=t(:,2).*iy;
                    template2=[template2;t];
                end
            end
        elseif n_dim==3
            ii=[1:n_use];
            template2=[];
            for ix=[-1 1]
                for iy=[-1 1]
                    for iz=[-1 1]
                        t=zeros(n_use,3);
                        t(:,1:n_dim)=repmat(ii(:),1,n_dim);;
                        t(:,1)=t(:,1).*ix;
                        t(:,2)=t(:,2).*iy;
                        t(:,3)=t(:,2).*iz;
                        template2=[template2;t];
                    end
                end
            end
        end
        template=[template;template2];
    end
    d=sqrt((template(:,1).^2+template(:,2).^2+template(:,3).^2));
    sort_data=sortrows([d(:),template],1);   
    template=sort_data(1:n_max,2:4);
    
    
    
end

if do_plot==1;
    
    figure
    s_size=[1:size(template,1)]./size(template,1);
    s_size=fliplr(124*(s_size/2));
    scatter3(template(:,1),template(:,2),template(:,3),s_size,'filled')
    hold on
    text(template(:,1)+.1,template(:,2)+.1,template(:,3)+.1,num2str([1:size(template,1)]'));
    %scatter3(0,0,0,124,10,'filled')
    hold off
    
    
    if (n_dim==2)&&(method==1);
        
        d_index=d.*NaN;
        
        subplot(1,2,1);
        imagematrix(d);
        hold on
        for i=1:n_max
            d_index(iy_c+template(i,2),ix_c+template(i,1))=i;
            t=text(ix_c+template(i,1),iy_c+template(i,2),num2str(i));
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