% sgenms_sgsim_test : an m-file test of the SGeMS interface
% 
% [XML,xml_entry,S]=sgems_read_xml('sgsim_ex3.xml');
% sgems_write_xml(XML,'sgsim_test.par');
% 
% return;
% %
% %
% py_file='sgems_sgsim_test.py';
% 
% disp('running SGeMS');
% sgems(py_file)
% 
% disp('cleaning up SGeMS');
% sgems_clean;
% 
% disp('Reading SGeMS results');
% 
% [d1,h1,dims1]=read_eas('SIM1.out');
% 
% imagesc(reshape(d1(:,1),dims1.nx,dims1.ny)')
% 
% 
% 
% d=sgems_grid('sgsim.par');
% 
% sgems.xml_file=XML;sgems=sgems_grid(XML);
% 
% S.xml_file='sgsim.par';S=sgems_grid(S)
% 
% 
% S.XML=sgems_read_xml('sgsim.par');
% sgems(sgems_grid_py(S));
% 
% S.XML=sgems_read_xml('sgsim.par');
% S=sgems_grid(S);
% 

%

S.XML=sgems_read_xml('sgsim.par');
S.XML.parameters.Nb_Realizations.value=20;
S.XML.parameters.algorithm.name='sgsim';

S.dim.nx=1*35;
S.dim.ny=1*53;

S.XML.parameters.Variogram.structure_1.ranges.max=5;
S.XML.parameters.Variogram.structure_1.ranges.medium=3;
S.XML.parameters.Variogram.structure_1.ranges.min=1;

S.XML.parameters.Property_Name.value='SGSIM';

S=sgems_grid(S);

U=S;
U.XML.parameters.algorithm.name='LU_sim';
U.XML.parameters.Property_Name.value='LU_SIM';
U=sgems_grid(U);

figure(1);
for i=1:min([S.XML.parameters.Nb_Realizations.value 12])
    subplot(4,3,i);
    pcolor(S.x,S.y,S.D(:,:,1,i)');shading interp;
    axis image
end