% sgems_test : testing various SGeMS algorithms available form mGstat 
%
% Call : 
%   S=sgems_test('sgsim');
%   S=sgems_test('lusim');
%   S=sgems_test('dssim');
%   S=sgems_test('snesim_std');
%
function [S,Sc]=sgems_test(alg,dim);
 
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

S.XML.parameters.Nb_Realizations.value=2;

S.dim=dim;

%%
% UNCONDITIONAL SIMULATION!!!
S=sgems_grid(S);


figure(1);
for i=1:min([S.XML.parameters.Nb_Realizations.value 12])
    subplot(4,3,i);
    pcolor(S.x,S.y,S.D(:,:,1,i)');shading interp;
    axis image
end
[axh,th]=watermark(sprintf('%s : unconditional simulation',alg));
set(th,'interpreter','none')
%%
% CONDITIONAL SIMULATION!!!
Sc=S;

% conditional data
d_obs=[30 10 0 0; 5 5 0 1];
header{1}='X';header{2}='Y';header{3}='Z';
header{4}='DATA';
Sc.f_obs='obs.sgems';
O=sgems_write_pointset(Sc.f_obs,d_obs,header,'OBS');

% conditional simulation
%Sc.XML.parameters.Hard_Data.grid=O.point_set;
%Sc.XML.parameters.Hard_Data.property=O.property_name{1};
%Sc.XML.parameters.Assign_Hard_Data.value=1;
%Sc.XML.parameters.Nb_Realizations.value=100;

% conditional simulation
Sc=sgems_grid(Sc);

figure;
subplot(1,2,1);
imagesc(reshape(mean(Sc.data'),S.dim.nx,S.dim.ny));colorbar;axis image
title('E-type mean')
subplot(1,2,2);
imagesc(reshape(var(Sc.data'),S.dim.nx,S.dim.ny));colorbar;axis image
title('E-type variance')
[axh,th]=watermark(sprintf('%s : conditional simulation',alg));
set(th,'interpreter','none')



return

