% geosoft_xyz_scatter
%
% Call:
%    geosoft_xyz_scatter(D,id_array,ix,iy,CHEAD,ilines_plot,do_log);
%
% See also: geosoft_xyz_read
%
function geosoft_xyz_scatter(D,id_array,ix,iy,CHEAD,ilines_plot,do_log);
if nargin<3, ix=1; end
if nargin<4, iy=2; end
if nargin<2, id_array=[]; end
if nargin<6
    ilines_plot=1:length(D);     
end
if isempty(ilines_plot);ilines_plot=1:length(D);end
if nargin<6, do_log=1;end



if isempty(id_array);
    for i=ilines_plot;
        i;
        plot(D{i}(:,ix),D{i}(:,iy),'-');
        hold on
    end
    hold off
    return
end


ssize=2;


nsp=ceil(sqrt(length(id_array)));

j=0;
for id=id_array
    j=j+1;

    if length(id_array)>1
        subplot(nsp,nsp,j);
    end


   
    for iline=ilines_plot
        
        i_ok=find( (D{iline}(:,ix)~=0) & (D{iline}(:,ix)~=0) );
        i_max=3000;
        ii=i_ok(unique(ceil(linspace(1,length(i_ok),i_max))));
        
        
        
        if (do_log==1);
            scatter(D{iline}(ii,ix), D{iline}(ii,iy),ssize,log(real(D{iline}(ii,id))),'filled')
        else
            scatter(D{iline}(ii,ix), D{iline}(ii,iy),ssize,(real(D{iline}(ii,id))),'filled')
        end
        hold on
    end
    hold off
    axis image
    xlabel(CHEAD{ix})
    ylabel(CHEAD{iy})
    if exist('CHEAD','var')
        title(sprintf('%s (icol=%d)',CHEAD{id},id),'Interp','none')
    end
    colormap(cmap_geosoft)
    colorbar
    drawnow;
end
