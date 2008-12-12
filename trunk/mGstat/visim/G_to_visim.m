% G_to_visim : Setup VISIM using classical d,G,m0,Cd
%
% use :
%    V=G_to_visim(x,y,z,d_obs,G,Cd,m0,parfile);
%
%    [x,y,z] : arrays indicating the geometry
%    [d_obs] : Number of data observations
%    [G]     [size(d_obs),nx*ny*nz] : Sensitivity kernel
%    [Cd]    [size(d_obs),size(d_obs)] : Data covariance table
%      or 
%    [Cd]    [size(d_obs),1] : uncorrelated data uncertainty
%    [m0]    [float] : Reference/background model parameter
%    [parfile] [string] : VISIM parameter file.
%
%
function V=G_to_visim(x,y,z,d_obs,G,Cd,m0,parfile);

    if nargin<6
        Cd=eye(length(d_obs)).*1e-3;
    end
    if nargin<7
        m0=0;
        sG=sum(G'); 
        m0=mean(d_obs(:)./sG(:));
    end


        
    V=visim_init(x,y,z);
    if nargin>7
        V.parfile=parfile;
    end
    [p,txt,e]=fileparts(V.parfile);
        
    
    nx=V.nx;ny=V.ny;
    nobs=length(d_obs);
    
    if  prod(size(Cd))==nobs
        Cd_diag=Cd;
        Cd=zeros(nobs,nobs);
        for i=1:nvol
            Cd(i,i)=Cd_diag(i);
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % WRITE VISIM PARAMETER FILES
    %V=read_visim('knud.par');
    [xx,yy]=meshgrid(V.x,V.y);
    for i=1:nobs;
        % NEXT LINE SHOULD BE CONSISTENT WITH VISIM PARAMETER FILE
        % G MATRIX NEEDS TO BE WRITTEN IN A SPEICIFIC MANNER ..
        %Gg=reshape(G(i,:),nx,ny)';
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
        if (((i/50)==round(i/50))|(i==nobs))
          progress_txt(i,nobs,'setting up kernel')
        end 
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

    
    V.fvolgeom.fname=sprintf('%s_volgeom.eas',txt);
    V.fvolsum.fname=sprintf('%s_volsum.eas',txt);

    write_eas(V.fvolgeom.fname,volgeom);
    write_eas(V.fvolsum.fname,volsum);

    % Write Cd
    if isfield(V,'fout')
        fCd=['datacov_',V.fout.fname];
    else
        [p,fCd]=fileparts(V.parfile);
        fCd=['datacov_',fCd,'.out'];        
    end
    write_eas(fCd,Cd(:));

    
    V.Va.a_hmax=.01;
    V.Va.a_hmin=.01;
    
    V.gmean=m0;
    V.gvar=1;
    
    V.cond_sim=3;
    
    %V.parfile=parfile;
    V=visim_init(V);
    write_visim(V);
    %
    V=read_visim(V.parfile);
    
    