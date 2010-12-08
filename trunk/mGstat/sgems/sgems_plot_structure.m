% sgems_plot_structure : plot data in a SGeMS data object
%
% Call : 
%   sgems_plot_structure(S,i_prop);
%
%      S: SGeMS matlab SGeMS data objcmat (as given by sgems_read)
%      i_prop : proerty number to plot (all if not given)
%
%  See also: sgems_read
%
% S=sgems_read('test.sgems');
% figure(1);
% subplot(1,2,1);plot(S,1); % first property
% subplot(1,2,2);plot(S,2); % second property
%
%
%
function sgems_plot_structure(S,i_prop);

if nargin<2
    
    nsp=ceil(sqrt(S.n_prop));
    for i=1:S.n_prop
        subplot(nsp,nsp,i);
        sgems_plot_structure(S,i);
        axis image;
    end
    
    if strcmp(S.type_def,'Point_set');
        sid=suptitle(S.point_set);
    elseif strcmp(S.type_def,'Cgrid');
        sid=suptitle(S.grid_name);
    end
    set(sid,'interpreter','none')
    return
end

if strcmp(S.type_def,'Point_set');
    % SCATTER
    if length(unique(S.xyz(:,3))==1)
        ndim=2;
    else 
        ndim=3;
    end
    
    if ndim==2
        scatter(S.xyz(:,1),S.xyz(:,2),10,S.data(:,i_prop),'filled');
    elseif ndim==3
        scatter(S.xyz(:,1),S.xyz(:,2),S.xyz(:,3),10,S.data(:,i_prop),'filled');
    end
    title(S.property_name{i_prop},'interpreter','none')
    mgstat_verbose(sprintf('%s : pointset:%s, property:%s ',mfilename,S.point_set,S.property_name{i_prop}));
    
elseif strcmp(S.type_def,'Cgrid');
    mgstat_verbose(sprintf('%s : gridname=%s, property=%s',mfilename,S.grid_name,S.property{i_prop}));
    
    if S.nz==1
        % ndim=2
        imagesc(S.x,S.y,S.D(:,:,1,i_prop))
    else
        % ndim=3
    end
    title(S.property{i_prop},'interpreter','none')
    axis image
end
