% sgems_example_to_from_image : convert image and use as training image

% LOAD IMAGE AND CONVERT TO SGeMS binary TRAINING IMAGE
%file_img='1609350318_7300f07360_m_d.jpg'; % larger pattern
file_img='1609350318_7300f07360_m_d.jpg'; % smaller pattern
f_out=sgems_image2ti(file_img);
TI=sgems_read(f_out);


% SETUP FILTERSIM
S=sgems_get_par('filtersim_cont');
S.ti_file=f_out;
S.XML.parameters.PropertySelector_Training.grid=TI.grid_name;
S.XML.parameters.PropertySelector_Training.property=TI.property{1};
S.XML.parameters.Nb_Realizations.value=1;


S.dim.x=[1:1:200];
S.dim.y=[1:1:200];
S.dim.z=[0];

% RUN SIMULATION
S=sgems_grid(S);


% VISUALIZE RELIZATION
subplot(1,2,1);
imagesc(TI.x,TI.y,TI.D(:,:,:,1)');axis image;
subplot(1,2,2);
imagesc(S.x,S.y,S.D(:,:,:,1)');axis image;

print('-dpng','sgems_example_ti_from_image');