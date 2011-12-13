% sgems_example_ppm : example of using PPM 
%

% get default snesim parameter file
S=sgems_get_par('snesim_std');
%S=sgems_get_par('filtersim_cate'); % SOFT PROB NOT YET IMPLEMENTED FOR
%FILTERSIM

% generate starting realization
S.XML.parameters.Nb_Realizations.value=1;
S=sgems_grid(S);


PPM_TARGET=sgems_read('snesim_std.sgems');

% loop over array of 'r' values
if ~exist('r_arr','var'),r_arr=linspace(0,1,25);end

nsp=ceil(sqrt(length(r_arr)));
for i=1:length(r_arr)
    % perform PPM with rc=r_arr(i)
    Sppm{i}=sgems_ppm(S,r_arr(i),PPM_TARGET);

    figure_focus(1);
    ax(i)=subplot(nsp,nsp,i);
    imagesc(S.x,S.y,Sppm{i}.D');axis image;
    colormap(1-gray)
    set(gca,'FontSize',6)
    title(sprintf('rc=%4.2g',r_arr(i)),'FontSize',10)
    drawnow
    
    figure_focus(2);
    imagesc(S.x,S.y,Sppm{i}.D');axis image;
    colormap(1-gray)
    M(i)=getframe;
    
end

figure_focus(1);
colormap(1-gray)
print('-dpng','-r200','sgems_example_ppm.png');
