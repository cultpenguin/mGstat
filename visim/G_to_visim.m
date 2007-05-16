% G_to_visim : Setup VISIM using classical d,G,m0,
function V=G_to_visim(x,y,z,d_obs,G,m0,Cd);

    if nargin<5
        m0=0;
    end
    if nargin<6
        Cd=eye(length(d_obs)).*1e-3;
    end
    
    V=visim_init;
    
    V.nx=length(x);
    V.xsiz=x(2)-x(1);
    V.xmn=x(1);

    V.ny=length(y);
    if V.ny>1
        V.ysiz=y(2)-y(1);
    else
        V.ysiz=V.xsiz;
    end
    V.ymn=y(1);

    V.nz=length(z);
    if V.nz>1
        V.zsiz=z(2)-z(1);
    else
        V.zsiz=V.ysiz;
    end
    V.zmn=z(1);

    nx=V.nx;ny=V.ny;
    
    V.x=[0:1:(V.nx-1)].*V.xsiz+V.xmn;
    V.y=[0:1:(V.ny-1)].*V.ysiz+V.ymn;
    V.z=[0:1:(V.nz-1)].*V.zsiz+V.zmn;

    
    nx=V.nx;ny=V.ny;
    nobs=length(d_obs);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % WRITE VISIM PARAMETER FILES
    %V=read_visim('knud.par');
    [xx,yy]=meshgrid(V.x,V.y);
    for i=1:nobs;
        Gg=reshape(G(i,:),ny,nx);
        
        ig=find(Gg>0);    
        Gg_sparse{i}.x=xx(ig);
        Gg_sparse{i}.y=yy(ig);
        Gg_sparse{i}.g=Gg(ig);        
        n(i)=length(ig);       
    end
    % SETUP VOLSUM AND VOLGEOM
    %nobs=1;
    volgeom=zeros(sum(n(1:nobs)),5);
    volsum=zeros(nobs,4);
    k=0;
    
    for i=1:nobs;
        progress_txt(i,nobs,'setting up kernel')
        for j=1:n(i);
            k=k+1;
            volgeom(k,1)=Gg_sparse{i}.x(j);
            volgeom(k,2)=Gg_sparse{i}.y(j);
            volgeom(k,3)=V.z(1);
            volgeom(k,4)=i;
            volgeom(k,5)=Gg_sparse{i}.g(j);
        end
        volsum(i,1)=i;
        volsum(i,2)=n(i);
        volsum(i,3)=d_obs(i);
        volsum(i,4)=Cd(i,i);
    end
    
    write_eas('knud_volgeom.eas',volgeom);
    write_eas('knud_volsum.eas',volsum);
    
    write_eas('visim_datacov_corr.eas',Cd(:));
    
    V.fvolgeom.fname='knud_volgeom.eas';
    V.fvolsum.fname='knud_volsum.eas';
    
    
    V.Va.a_hmax=.01;
    V.Va.a_hmin=.01;
    
    V.gmean=m0;
    V.gvar=1;
    