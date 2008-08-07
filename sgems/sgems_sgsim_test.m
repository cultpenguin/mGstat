% sgenms_sgsim_test : an m-file test of the SGeMS interface

[XML,xml_entry,S]=sgems_read_xml('sgsim_ex3.xml');
sgems_write_xml(XML,'sgsim_test.xml');
return;
%
%
py_file='sgems_sgsim_test.py';

disp('running SGeMS');
sgems(py_file)

disp('cleaning up SGeMS');
sgems_clean;

disp('Reading SGeMS results');

[d1,h1,dims1]=read_eas('SIM1.out');

imagesc(reshape(d1(:,1),dims1.nx,dims1.ny)')