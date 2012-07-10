% jura : Jura data set from Pierre Goovaerts book
%
% Call : 
%  [d_prediction,d_transect,d_validation,h_prediction,h_transect,h_validation,x,y,pos_est]=jura;
%  dx=1;
%  [d_prediction,d_transect,d_validation,h_prediction,h_transect,h_validation,x,y,pos_est]=jura(dx);
%
%  d_prediction : [259x11] matrix of data observations
%  h_prediction : {11} cell structure with header names for observations
%  d_validation : [100x11] matrix of validation data
%  h_validation : {11} cell structure with header names for validation data
%  d_transect : [106x5] matrix of 1D transect data
%  h_transect : {5} cell structure with header names for transect data
%


function [d_prediction,d_transect,d_validation,h_prediction,h_transect,h_validation,x,y,pos_est]=jura(dx);
if nargin<1
    dx=.1;
end

if nargout==0;
    % plot data
    
    close all;
    [d_prediction,d_transect,d_validation,h_prediction,h_transect,h_validation]=jura;
    
    %% transect
    figure;set_paper('landscape');
    n=length(h_transect);
    for i=2:(n)
        subplot(n-1,1,i-1);
        plot(d_transect(:,1),d_transect(:,i),'-');
        hold on
        plot(d_transect(:,1),d_transect(:,i),'.','MarkerSize',22);
        hold off
        ylabel(h_transect{i})
        xlabel(h_transect{1})
        set(gca,'xlim',[min(d_transect(:,1)),max(d_transect(:,1))]);
    end
    suptitle('JURA TRANSECT')
    print_mul('jura_transect')
    
    %% PREDICTION/ VALIDATION
    figure;set_paper('landscape');
    n=length(h_prediction);
    for i=1:(n-2)
        subplot(3,3,i);
        scatter(d_prediction(:,1),d_prediction(:,2),12,d_prediction(:,i+2));
        hold on
        scatter(d_validation(:,1),d_validation(:,2),12,d_validation(:,i+2),'filled');
        hold off
        xlabel(h_prediction{1})
        ylabel(h_prediction{2})
        title(h_prediction{i+2})
        axis image
        set(gca,'xlim',[min(d_prediction(:,1)),max(d_prediction(:,1))]);
        set(gca,'ylim',[min(d_prediction(:,2)),max(d_prediction(:,2))]);
    colorbar_shift;
    end
    
    suptitle('JURA PREDICTION(o)/VALIDATION(.)')
    print_mul('jura_prediction_validation')
    return
end

data_dir = [mgstat_dir,filesep,'examples',filesep,'data',filesep,'jura',filesep];

[d_prediction,h_prediction]=read_eas([data_dir,'prediction.dat']);
[d_transect,h_transect]=read_eas([data_dir,'transect.dat']);
[d_validation,h_validation]=read_eas([data_dir,'validation.dat']);

nanval=-99;
d_prediction(find(d_prediction==nanval))=NaN;
d_transect(find(d_transect==nanval))=NaN;
d_validation(find(d_validation==nanval))=NaN;

x=min(d_prediction(:,1)):dx:max(d_prediction(:,1));
y=min(d_prediction(:,2)):dx:max(d_prediction(:,2));
[x_grid,y_grid]=meshgrid(x,y);
pos_est=[x_grid(:) y_grid(:)];

