% plot_scale : plot scale to figure
%
% Call:
%    plot_scale(ax,len,pos,FontSize)
%
%    ax: axis (gca)
%    len [1,2]: length of scale length in each direction
%    pos [1],[2],[3] or [4]: Position of scale plot.
%        [NW],[SW],[NE],[SE]
%
%
% Example
%        imagesc(peaks);
%        hold on;
%        plot_scale(gca,[15 15],3);
%        hold off;
%        axis image
%
%

function plot_scale(ax,len,pos,FS,txt)

    if nargin==0
        ax=gca;
    end
    if nargin==1
    end

    if nargin<3, pos=3;end
    if nargin<4, FS=6; end
    if nargin<5, txt=''; end
    
    
    dc=0.05;
    
    
    Xlim = get(ax,'Xlim');
    Ylim = get(ax,'Ylim');
    Zlim = get(ax,'Zlim');
    
    
    dx=abs(diff(Xlim));
    dy=abs(diff(Ylim));
    dz=abs(diff(Zlim));
    
    
    
    if nargin<2
        lx=0.1;
        ly=0.1;
        lz=0.1;
        lenx=lx*dx;
        leny=ly*dy;
        lenz=lz*dz;
    else
        if length(len)==1, len(2)=len(1); end
        lenx=len(1);
        leny=len(2);
        % lenz=len(3);
        lx=lenx/dx;
        ly=leny/dy;
    end
    
    
    if pos==1
        xc=dc;
        yc=dc;
        zc=dc;
    elseif pos==2
        xc=dc;
        yc=1-dc-ly;
        zc=dc;
    elseif pos==3
        xc=1-dc-lx;
        yc=dc;
        zc=dc;
    else 
        xc=1-dc-lx;
        yc=1-dc-ly;
        zc=dc;
    end
    if isempty(txt)
        txt_x=num2str(lenx);
        txt_y=num2str(lenx);        
    else
        txt_x=txt;txt_y=txt;
    end
    

    plot_xscale=1;
    plot_yscale=0;
    % X-scale
    if plot_xscale==1;
        y0=(Ylim(1)+yc*dy);
        plot([Xlim(1)+xc*dx Xlim(1)+(xc+lx)*dx],[1 1].*y0,'k-')
        tx=text([Xlim(1)+xc*dx]+dx*lx/2,(Ylim(1)+yc*dy),txt_x);
        set(tx,'HorizontalAlignment','Center')
        set(tx,'VerticalAlignment','Top')
        set(tx,'FontSize',FS,'FontName','Arial')        
        if plot_yscale==0;           
            x1=Xlim(1)+xc*dx;
            x2=Xlim(1)+(xc+lx)*dx;
            plot([1 1].*x1,[-1 1].*(0.10*(x2-x1))+y0,'k-')
            plot([1 1].*x2,[-1 1].*(0.10*(x2-x1))+y0,'k-')        
        end
    end
    % Y-scale
    if plot_yscale==1;
        plot([1 1].*(Xlim(1)+xc*dx),[Ylim(1)+yc*dy Ylim(1)+(yc+ly)*dy],'k-')
        ty=text([Xlim(1)+xc*dx],(Ylim(1)+yc*dy)+dy*ly/2,txt_y);
        set(ty,'HorizontalAlignment','Center')
        set(ty,'VerticalAlignment','Bottom')
        set(ty,'FontSize',FS,'FontName','Arial')
        set(ty,'Rotation',90)
    end