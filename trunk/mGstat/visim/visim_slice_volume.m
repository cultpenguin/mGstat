% visim_slice_volume : slice selected volume aveare data from VISIM project
%
% Call : 
%    visim_slice_volume(V,ivol,name)
%
%
function visim_slice_volume(V,ivol,name)
    
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
    
    keyboard
    
    volsum_new=volsum(ivol,:);
    volsum_new(:,1)=1:1:length(ivol);
        
    [p,f]=fileparts(V.parfile);
    
    fvolsum=sprintf('%s_volsum.eas',f);
    fvolgeom=sprintf('%s_volgeom.eas',f);
    
    write_eas(fvolsum,volsum_new);
    write_eas(fvolgeom,volgeom_new);
    
    V.parfile=sprintf('%s_%d.par',f,length(ivol));
    V.fvolgeom.fname=fvolgeom;
    V.fvolsum.fname=fvolsum;
    
    write_visim(V);
        
    disp(sprintf('Writing %s',V.parfile))
    
    
    