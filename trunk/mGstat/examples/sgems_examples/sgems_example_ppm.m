% sgems_example_ppm : example of using PPM 
%

% get default snesim parameter file
S=sgems_get_par('snesim_std');
%S=sgems_get_par('filtersim_cate'); % SOFT PROB NOT YET IMPLEMENTED FOR
%FILTERSIM

% generate starting realization
S.XML.parameters.Nb_Realizations.value=1;
S=sgems_grid(S);
S.O=sgems_read('snesim_std.sgems');

% loop over array of TAU values
r_arr=linspace(0,1,25);
Sppm{1}=S;
for i=2:length(r_arr)
    % perform PPM with tau=r_arr(i)
    Sppm{i}=sgems_ppm(S,S.O,r_arr(i));
end

% Visualize results
figure;set_paper('landscape');
title('TI')
for i=1:length(r_arr)
    ax(i)=subplot(5,5,i);
    imagesc(S.x,S.y,Sppm{i}.D');axis image;
    set(gca,'FontSize',6)
    title(sprintf('tau=%4.2g',r_arr(i)),'FontSize',10)
end
colormap(1-gray)
print('-dpng','-r200','sgems_example_ppm.png');
