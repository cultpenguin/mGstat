% geosoft_xyz_plot(D,LINE,BOT,TOP,ilines_plot);
%
% Call: 
%    geosoft_xyz_plot(D,LINE,BOT,TOP,ilines_plot);
%
% See also: geosoft_xyz_read
%
function geosoft_xyz_plot(D,LINE,BOT,TOP,ilines_plot);
if nargin<5
    ilines_plot=1;
end

clim=[1 3];
cmap=colormap;
ncolors=size(cmap,1);


nlayers=min([length(BOT) size(D{1}.RES,1)]);

ids=20;
lw=3;

for iline=ilines_plot;
    figure(iline);clf;set_paper;
    
    nlayers=min([length(BOT) size(D{1}.RES,1)]);
    
    ns=size(D{iline}.RES,2);
    %imagesc(X,BOT,log10(D{iline}.RES));
    
    % loop over 
    for is=1:ids:ns;        
        X=is;
        %X=D{iline}.UTMX(is);
        %X=D{iline}.UTMY(is);
        for il=1:nlayers;
            try
                logres=log10(D{iline}.RES(il,is));
                if ~isnan(logres)
                icol=interp1(linspace(clim(1),clim(2),ncolors),1:ncolors,logres,'nearest','extrap');
                col=cmap(icol,:);
                plot([1 1].*X,D{iline}.ELEV(is)+[BOT(il) TOP(il)],'k-','color',col,'LineWidth',lw);
                if (is==1&il==1);hold on;end
                end
            catch
            end
        end
        
    end
    hold off
    daspect([10 1 1])
    txt=sprintf('Line%d',LINE(iline));
    title(txt)
    try
    print_mul(txt)
    end
end
