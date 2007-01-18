% scatter_hpd : calculate 2D HPD region
%
% [prob,levels,x_arr,y_arr,f2,c2]=scatter_hpd(x,y,p,p_levels,x_arr,y_arr)
%

function [prob,levels,x_arr,y_arr,f2,c2]=scatter_hpd(x,y,p,p_levels,x_arr,y_arr)
    
    x=x(:)';
    y=y(:)';
    p=p(:)';

    if nargin<4
        p_levels=[0:.1: .99];
        p_levels=[0 .05 0.9 ];
    end
    dx=.01*(max(x)-min(x));
    dy=.01*(max(y)-min(y));
    if nargin<5
        nc=30;
        x_arr=linspace(min(x),max(x),nc);
        y_arr=linspace(min(y),max(y),nc);
    end
    
    [xx,yy]=meshgrid(x_arr,y_arr);
    
    
    x=[x min(x)-dx max(x)+dx max(x)+dx min(x)-dx];
    y=[y min(y)-dy min(y)-dy max(y)+dy max(y)+dy];
    p=[p 0 0 0 0];

    prob=griddata(x,y,p,xx,yy,'linear');
    prob(find(isnan(prob)))=0;
    
    %figure(1);      
    %f1=imagesc(x_arr,y_arr,prob);
    %set(gca,'ydir','normal');
    
    levels=hpd_2d(prob,p_levels);
    levels2=hpd_2d(p,[0:.1:.9]);
    [c2,f2]=contourf(x_arr,y_arr,prob,levels);

    doUpdateColor=1;
    if doUpdateColor==1;
        ch=get(f2,'Children');
        cmap=colormap(gray);
        %        cmap=colormap(jet);
        cmap=flipud(cmap);
        
        Cdata=cell2mat(get(ch,'Cdata')');
        UniqueCdata=unique(Cdata);
        nUniqueCdata=length(UniqueCdata);
        
        icol=round(linspace(1,size(cmap,1),nUniqueCdata));
        for i=1:nUniqueCdata;
            for iobj=findobj('Cdata',UniqueCdata(i))
                cmap(icol(i),:);
                set(iobj,'FaceColor',cmap(icol(i),:));
            end
        end
    end
    
    %set(f2,'TextList',[p_levels])
    legend
    % clabel(c2,f2,'fontsize',15,'color','r','rotation',0)
    hold on
    %contour(x_arr,y_arr,prob,levels,'color',[.9 .9 .9 ]);
    hold off
    %colormap(1-gray)
