function sgems_test(alg);
 
if nargin==0;
    alg=sgsim;
end

mgstat_verbose(sprintf('%s : Testing SGeMS algorithm ''%s''',mfilename,alg),10)

% sgenms_sgsim_test : an m-file test of the SGeMS interface

alg='lusim';

sgems_get_par(alg);
par_file=[alg,'.par'];

if ~(exist(par_file,'file')==2)
    mgstat_verbose(sprintf('%s : Could not locate %s for %s-type SGeMS',mfilename,par_file,alg),10)
    return
end

S.XML=sgems_read_xml(par_file);
%S.XML.parameters.Nb_Realizations.value=120;
S.XML.parameters.algorithm.name=alg;

%S.dim.nx=1*35;
%S.dim.ny=1*53;

%S.XML.parameters.Variogram.structure_1.ranges.max=35;
%S.XML.parameters.Variogram.structure_1.ranges.medium=35;
%S.XML.parameters.Variogram.structure_1.ranges.min=1;
%S.XML.parameters.Variogram.nugget=0.0001;

S.XML.parameters.Property_Name.value=alg;

S=sgems_grid(S);

return


Scond=S;
x=[6 30 27 10];header{1}='x';
y=[30 27 10 6];header{2}='y';
z=[0 1 2 1];header{3}='z';
name='COND';
filename='cond.sgems';
point2sgems(filename,[x(:) y(:) z(:)],header,name);
Scond.XML.parameters.Hard_Data.grid=name;
Scond.XML.parameters.Hard_Data.property=header{3};
Scond.f_obs=filename;
Scond=sgems_grid(Scond);

[em,ev]=etype(Scond.D);
subplot(2,1,1);imagesc(em);colorbar;axis image
subplot(2,1,2);imagesc(ev);colorbar;axis image
return

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