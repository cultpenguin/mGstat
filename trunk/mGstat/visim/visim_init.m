% visim_init : create a reference parameter file.
%
% Call without arguemtnt for a reference file for unconditional simulation
%
% Call :
%    V=visim_init(x,y,z,V);
%
function V=visim_init(x,y,z,V);

    if nargin==1
        if isstruct(x);
            V=x;
            V=visim_init(V.x,V.y,V.z,V);
            return;
        end
    end
    
    if ((nargin==0)|(nargin<4))
        [p]=fileparts(which('visim.m'))        ;
        f=[p,filesep,'visim_default'];
        load([p,filesep,'visim_default']);
        if nargin==0
            return
        end
    end
     
    
    if nargin<2
        y=[1];
    end	
    
    if nargin<3
        z=[1];
    end	

    
    V.Va.a_hmax=(max(x)-min(x))/2;
    V.Va.a_hmin=(max(y)-min(y))/2;
    V.Va.a_vert=(max(z)-min(z))/2;

    
    V.xmn=x(1);
    V.nx=length(x);
    if V.nx==1;
        V.xsiz=1;
    else
        V.xsiz=x(2)-x(1);
    end
    V.x=[0:1:(V.nx-1)].*V.xsiz+V.xmn;
    
    V.ymn=y(1);
    V.ny=length(y);
    if V.ny==1
        V.ysiz=1;
    else	
        V.ysiz=y(2)-y(1);
    end	
    V.y=[0:1:(V.ny-1)].*V.ysiz+V.ymn;
    
    V.zmn=z(1);
    V.nz=length(z);
    if V.nz==1;
        V.zsiz=1;
    else
        V.zsiz=z(2)-z(1);
    end	
    V.z=[0:1:(V.nz-1)].*V.zsiz+V.zmn;
    
    if V.ccdf==1;
        try
            d=read_eas(V.refhist.fname);
            V.tail.zmin=min(d(:,1));
            V.tail.zmax=max(d(:,1));
            
            nugget=V.Va.nugget;
            % SET MEAN AND VAR)IANCE
            V.gmean=mean(d(:,1));
            V.gvar=mean(d(:,1));
            V.Va.cc=(1-nugget)*V.gvar;
            V.Va.nugget=nugget;
                        
        catch
        end
    end
    
    % MAKE SURE SILL IS OK
    nugget=V.Va.nugget;
    V.Va.cc=(1-nugget)*V.gvar;
    V.Va.nugget=nugget;
    
    
    % MAKE SURE VOLGEOM IS SETUP PROPERLY
    
    