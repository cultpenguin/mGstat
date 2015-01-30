function d=dsim_get_distance(ny,nx,i_node,i_good,DIST)

 for i=1:length(i_good)
        [iiy_n,iix_n]=ind2sub_2d([ny,nx],i_node);
        [iiy_g,iix_g]=ind2sub_2d([ny,nx],i_good(i));
       
        iiy=abs(iiy_n-iiy_g)+1;
        iix=abs(iix_n-iix_g)+1;
        ind = sub2ind([[ny,nx]],iiy,iix);
        d(i)=DIST(1,ind);
 end
        