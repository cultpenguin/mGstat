% sgems_test : testing various SGeMS algorithms available form mGstat 
%
% Call : 
%   S=sgems_test('sgsim');
%   S=sgems_test('lusim');
%
function S=sgems_test(alg,dim);
 
if nargin==0;
    alg='sgsim';
end

if nargin<2
    dim.nx=50;
    dim.ny=50;
    dim.nz=1;
end


mgstat_verbose(sprintf('%s : Testing SGeMS algorithm ''%s''',mfilename,alg),10)


S=sgems_get_par(alg);

S.dim=dim;

S=sgems_grid(S);


figure(1);
for i=1:min([S.XML.parameters.Nb_Realizations.value 12])
    subplot(4,3,i);
    pcolor(S.x,S.y,S.D(:,:,1,i)');shading interp;
    axis image
end
suptitle(alg);

% MAKE A TEST WITH CONDITIONAL SIMULATION!!!
S2=S;

d_obs=[10 10 0 0; 1 1 0 3];
header{1}='X';header{2}='Y';header{3}='Z';
header{4}='DATA';
S2.f_obs='obs.sgems';
O=sgems_write_pointset(S2.f_obs,d_obs,header,'OBS');

% conditional simulation

%O=sgems_read(S.f_obs,0);
%S.XML.parameters.Hard_Data.grid=O.point_set;
%S.XML.parameters.Hard_Data.property=O.property_name{1};
%S.XML.parameters.Assign_Hard_Data.value=0;
%S2=S;
S2.XML.parameters.Nb_Realizations.value=100;
S2=sgems_grid(S2);

figure;
subplot(1,2,1);
imagesc(reshape(mean(S2.data'),S.dim.nx,S.dim.ny));axis image;colorbar
title('E-type mean')
subplot(1,2,2);
imagesc(reshape(var(S2.data'),S.dim.nx,S.dim.ny));axis image;colorbar
title('E-type variance')



return

