% visim_set_conditional_point : set conditional point data
%
%
%
function V=visim_set_conditional_point(V,x,y,z,val,add)
    if nargin==0;
        %V=visim_init(0:.25:40,0:.25:40);
        load visim_default;    
        y=[V.y(1):(V.y(2)-V.y(1)):80];
        x=[V.x(1):(V.x(2)-V.x(1)):50];
        %x=1:1:150;
        %y=1:1:160;
        V.x=x;V.y=y;
        V=visim_init(V.x,V.y);
        V.debuglevel=-1;
        [xx,yy]=meshgrid(V.x,V.y);
        region=zeros(size(xx))+1;
        dy=5;
        y_arr=[min(V.y):dy:max(V.y)];
        NR=length(y_arr);
        for iy=1:length(y_arr)
            region(find(yy>=y_arr(iy)))=iy;
            Va{iy}=V.Va;
            Va{iy}.ang1=(iy/NR)*180-90;
            Va{iy}.a_hmax=60;
            Va{iy}.a_hmin=5;
        end
        for i=1:NR;
            
            % SET CONDITIONAL IF NEEDED
            if i>1
                ii=find(region<i);
                x=xx(ii);
                y=yy(ii);
                z=y.*0+V.z(1);
                val=V.D(:,:,1)';
                val=val(ii);
                V=visim_set_conditional_point(V,x,y,z,val);
                
            end
            
            V.Va=Va{i};
            V = visim(V);
            
        end
        imagesc(V.x,V.y,V.D(:,:,1)');
        axis image
        title('non-stationary prior Cm')
        return
    end
    

    if nargin<6
        add=0;
    end
    [p,f]=fileparts(V.parfile);
    fcond=sprintf('%s_point.eas',f);
    write_eas(fcond,[x(:) y(:) z(:) val(:)]);
    V.fconddata.fname=fcond;
    V.cols=[1 2 3 4];
    
    if (V.cond_sim)==0;
        V.cond_sim=2;
    elseif (V.cond_sim)==3
        V.cond_sim=1;
    end
    
    
    
    
    