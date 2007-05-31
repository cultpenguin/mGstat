% visim_slice_volume : slice selected volume average data from VISIM project
%
% Call : 
%    V=visim_slice_volume(V,ivol,name)
%
% V : visim structure
% ivol : volumes to be sliced (ex ivol=[10:10:100])
% name : name to be appended to V.parfile (default is string(length(ivol))
%
% TMH/2006
% 
function V=visim_slice_volume(V,ivol,name)
    
    if nargin<1
        help visim_slice_volume
        return
    end
    
    if isstruct(V)~=1
        V=read_visim(V);
    end
    
    if nargin<2
        nvol=size(V.fvolsum.data,1);
        ivol=[10:10:nvol];
    end

    if nargin<3
        name=sprintf('%d',length(ivol));
    end

    
    volsum=read_eas(V.fvolsum.fname);
    volgeom=read_eas(V.fvolgeom.fname);
    
    nvol=size(volsum,1);

        
    % SLICE data covariance if it exists
    sliceCd=0;
    try
          % Write Cd
          if isfield(V,'fout')
            fCd=['datacov_',V.fout.fname];
          else
            [p,fCd]=fileparts(V.parfile);
            fCd=['datacov_',fCd,'.out'];
          end
          Cd=reshape(read_eas(fCd),nvol,nvol);
          Cd=Cd(ivol,ivol);
          sliceCd=1;
    catch
    end
    
    

    volgeom_new=[];
    for i=1:length(ivol);
        ii=find(volgeom(:,4)==ivol(i));

        vv=volgeom(ii,:);
        vv(:,4)=i;
        
        if i==1
            volgeom_new=vv;
        else
            volgeom_new=[volgeom_new;vv];            
        end
    end
    
    volsum_new=volsum(ivol,:);
    volsum_new(:,1)=1:1:length(ivol);
        
    [p,f]=fileparts(V.parfile);
    V.parfile=sprintf('%s_%s.par',f,name);
    [p,f]=fileparts(V.parfile);
    
    fvolsum=sprintf('%s_volsum.eas',f);
    write_eas(fvolsum,volsum_new);

    fvolgeom=sprintf('%s_volgeom.eas',f);
    write_eas(fvolgeom,volgeom_new);
    
    if sliceCd==1 
      fCd_slice=sprintf('datacov_%s.out',f);
      write_eas(fCd_slice,Cd(:));
    end
    
    V.fvolgeom.fname=fvolgeom;
    V.fvolsum.fname=fvolsum;
    
    % SLICE DATA COVARIANCE IF IT EXISTS
    
    
    write_visim(V);
        
    disp(sprintf('Writing %s',V.parfile))
    V=read_visim(V.parfile);
    
    