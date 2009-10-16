function [cmap_out,d_lev]=cmap_quantile(d,cmap);


if nargin<2
    cmap=colormap;
end
n_cmap=size(cmap,1);

d_sort=sort(d(:));
n_d=length(d_sort);

nlim=20;
i_d_sort=round(linspace(1,n_d,nlim));
i_cmap=round(linspace(1,n_cmap,nlim));



d_lev=d_sort(i_d_sort);

norm_d_lev=d_lev-min(d_lev);
norm_d_lev=norm_d_lev./max(norm_d_lev);

try
    
    for i=1:n_cmap;
        i_cmap=norm_d_lev(i)*(n_cmap-1)+1;
        %disp(i_cmap);
        
        cmap_out(i,1)=interp1(1:n_cmap,cmap(:,1),i_cmap);
        cmap_out(i,2)=interp1(1:n_cmap,cmap(:,2),i_cmap);
        cmap_out(i,3)=interp1(1:n_cmap,cmap(:,3),i_cmap);
    end
catch
    cmap_out=cmap;
end