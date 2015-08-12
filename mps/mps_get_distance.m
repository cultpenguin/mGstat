% mps_get_distance: Compute distance (using distance matrix)

function [d,options]=mps_get_distance(ny,nx,i_node,i_good,options)



%% PRECALCULATED DISTANCE MATRIX
if ~isfield(options,'DIST');
   
    if ~isfield(options,'precalc_dist_full');
        if (nx*ny)<=10000;
            options.precalc_dist_full=1;
        else
            options.precalc_dist_full=0;
        end
    end

    [XX,YY]=meshgrid(1:nx,1:ny);
    X=[XX(:) YY(:)];
    if options.verbose>0;fprintf('%s: Precalculating Distance Matrix - start\n',mfilename);end
    if options.precalc_dist_full==0;
        X(:,1)=X(:,1)-X(1,1);
        X(:,2)=X(:,2)-X(1,2);
        options.DIST=sqrt(sum(X'.^2));
    else
        options.DIST=pdist_tmh(X);
    end
    if options.verbose>0;fprintf('%s: Precalculating Distance Matrix - stop\n',mfilename);end   
    
end

if min(size(options.DIST))==1
    % USE ONLY SIMPLE 1D DISTANCE MATRIX
    for i=1:length(i_good)
        [iiy_n,iix_n]=ind2sub_2d([ny,nx],i_node);
        [iiy_g,iix_g]=ind2sub_2d([ny,nx],i_good(i));
        
        iiy=abs(iiy_n-iiy_g)+1;
        iix=abs(iix_n-iix_g)+1;
        ind = sub2ind_2d([[ny,nx]],iiy,iix);
        d(i)=options.DIST(1,ind);
    end
else
    % USE FULL (FAST) DISTANCE MATRIX
    d=options.DIST(i_node,i_good);    
end
