% sgems_demo : testing various SGeMS algorithms available form mGstat 
%
% Call : 
%   S=sgems_test('sgsim');
%   S=sgems_test('lusim');
%   S=sgems_test('dssim');
%   S=sgems_test('snesim_std');
%
function [S,Sc]=sgems_demo(alg,dim);
 
if nargin==0;
    alg{1}='sgsim';
    alg{2}='lusim';
    alg{3}='dssim';
    alg{4}='snesim_std';
    for i=1:length(alg);        
        [S,Sc]=sgems_demo(alg{i});
    end
    return
end

if nargin<2
    dim.nx=50;
    dim.ny=50;
    dim.nz=1;
end

mgstat_verbose(sprintf('%s : Testing SGeMS algorithm ''%s''',mfilename,alg),10);

S=sgems_get_par(alg);
S.XML.parameters.Nb_Realizations.value=25;
S.dim=dim;

%%
% UNCONDITIONAL SIMULATION!!!
S=sgems_grid(S);

%%
% CONDITIONAL SIMULATION!!!
Sc=S;

% conditional data
Sc.d_obs=[30 10 0 0; 5 5 0 1];
%header{1}='X';header{2}='Y';header{3}='Z';
%header{4}='DATA';
%Sc.f_obs='obs.sgems';
%O=sgems_write_pointset(Sc.f_obs,d_obs,header,'OBS');

% conditional simulation
Sc=sgems_grid(Sc);

cax_mean=[-1 1];
cax_var=[0 2];

nsp=ceil(sqrt(S.XML.parameters.Nb_Realizations.value));



figure;
for i=1:min([S.XML.parameters.Nb_Realizations.value 12])
    subplot(nsp,nsp,i);
    %pcolor(S.x,S.y,S.D(:,:,1,i)');shading interp;
    imagesc(S.x,S.y,S.D(:,:,1,i)');shading interp;
    title(sprintf('#%02d',i))
    axis image
end
[axh,th]=watermark(sprintf('%s : unconditional simulation',alg));
set(th,'interpreter','none');

figure;
for i=1:min([S.XML.parameters.Nb_Realizations.value 12])
    subplot(nsp,nsp,i);
    %pcolor(Sc.x,Sc.y,Sc.D(:,:,1,i)');shading interp;
    imagesc(Sc.x,Sc.y,Sc.D(:,:,1,i)');shading interp;
    title(sprintf('#%02d',i))
    axis image
end
[axh,th]=watermark(sprintf('%s : conditional simulation',alg));
set(th,'interpreter','none');

figure;
[em,ev]=etype(S.D);
subplot(2,2,1);
imagesc(S.x,S.y,em);colorbar;axis image;caxis(cax_mean)
title('E-type mean ')
subplot(2,2,2);
imagesc(S.x,S.y,ev);colorbar;axis image;;caxis(cax_var)
title('E-type variance')

[em_c,ev_c]=etype(Sc.D);
subplot(2,2,3);
imagesc(S.x,S.y,em_c);colorbar;axis image;caxis(cax_mean)
title('E-type mean (conditional)')
subplot(2,2,4);
imagesc(S.x,S.y,ev_c);colorbar;axis image;;caxis(cax_var)
title('E-type variance (conditional)')

[axh,th]=watermark(sprintf('%s : conditional simulation',alg));
set(th,'interpreter','none')


return

