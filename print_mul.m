% print_mul : prints both EPS and PNG figures of current plot
%
%
% Call :
%   print_mul('test') : prints test.eps and test.png
%
% In case 'mogrify' is available on the system
% the png file will be trimmed and optionall 
% A specific color will be made transparent :
%
%   print_mul('test',red) 
%       also creates trim_test.png
%
%   print_mul('test',1) 
%       also creates trim_test.png, with transparent white color
%
%   print_mul('test','red') 
%       also creates trim_test.png, with transparent red color
%
% /TMH 12/2005
%

function print_mul(fname,color,trim);

    watermark(fname);

    print(gcf, '-dtiff', [fname,'.tiff'] )
    print(gcf, '-dpng', [fname,'.png'] )
    print(gcf, '-dpdf', [fname,'.pdf'] ); % BAD RESOLUTION FOR IMAGE PLOTS
    print(gcf, '-depsc2', [fname,'.eps'] )
    return
    print(gcf, '-dpng','-r300', [fname,'.png'] )
    print(gcf, '-dpdf','-r300', [fname,'.pdf'] ); % BAD RESOLUTION FOR IMAGE PLOTS
    print(gcf, '-depsc2','-r300', [fname,'.eps'] )
    return
    %print(gcf, '-dpng','-r72', [fname,'_low.png'] )

    %cmap=colormap;
    %colormap gray;
    
    %print(gcf, '-depsc', [fname,'.eps'] )
    print(gcf, '-dpdf','-r300', [fname,'.pdf'] ); % BAD RESOLUTION FOR IMAGE PLOTS
    %colormap(cmap);
    %print(gcf, '-depsc2', [fname,'_color.eps'] )
    
    saveas(gcf,[fname,'.fig'],'fig');
    
    
    return
    
    [a,mogrifybin]=unix('which mogrify');
    mogrifybin=mogrifybin(1:length(mogrifybin)-1);
    fname_trim=sprintf('trim_%s',fname);
    
    if nargin<3
        trim=0;
    end
    
    if (trim==0);
        return
    end
    
    if exist(mogrifybin)==2,
        
        system(sprintf('cp %s.png %s.png',fname,fname_trim));    
        if nargin==1
            system(sprintf('%s -trim %s.png',mogrifybin,fname_trim));
            
        else
            if isnumeric(color)
                if color==1;
                    color='white';
                else
                    return
                end
            end
            
            system(sprintf('%s -trim -transparent %s %s.png',mogrifybin,color,fname_trim));
        end
    end
    
    
