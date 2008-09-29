% sgems_demo : testing various SGeMS algorithms available from mGstat 
%
% Call : 
%   S=sgems_test('sgsim');
%   S=sgems_test('lusim');
%   S=sgems_test('dssim');
%   S=sgems_test('snesim_std');
%
% To run the test on all available algorithms use :
%   sgems_test;
%
% A calculation time of -1 indicates that the demo could
%   not be run
% 
%
function [S,Sc,t]=sgems_demo(alg,dim);
 
if nargin==0;
    alg=sgems_get_par;
    ii=1:length(alg);
    %ii=[2,4,5]
    for i=ii; 
        try
            [S{i},Sc{i},t(i)]=sgems_demo(alg{i});
        catch
            t(i)=-1;
        end
    end

    disp('--- demo computation times ---')
    for i=ii;
        try
            disp(sprintf('demo : alg:%20s, time=%04ds',alg{i},round(t(i))))
        end
    end
    return
end

tic;

if nargin<2
    dim.nx=50;
    dim.ny=30;
    dim.nz=1;
end

mgstat_verbose(sprintf('%s : Testing SGeMS algorithm ''%s''',mfilename,alg),10);

S=sgems_get_par(alg);
S.XML.parameters.Nb_Realizations.value=1;
S.dim=dim;

%%
% UNCONDITIONAL SIMULATION!!!
S=sgems_grid(S);

%%
% CONDITIONAL SIMULATION!!!
Sc=S;

% conditional data
Sc.d_obs=[18 13 0 0; 5 5 0 1; 2 28 0 1];
%header{1}='X';header{2}='Y';header{3}='Z';
%header{4}='DATA';
%Sc.f_obs='obs.sgems';
%O=sgems_write_pointset(Sc.f_obs,d_obs,header,'OBS');

save Sc Sc
% conditional simulation
Sc=sgems_grid(Sc);



t=toc;


% VISUALIZATIONS
cax_mean=[-1 1];
cax_var=[0 .2];

nsp=ceil(sqrt(S.XML.parameters.Nb_Realizations.value));

figure;set_paper('landscape')
for i=1:S.XML.parameters.Nb_Realizations.value
    subplot(nsp,nsp,i);
    %pcolor(S.x,S.y,S.D(:,:,1,i)');shading interp;
    imagesc(S.x,S.y,S.D(:,:,1,i)');
    caxis(cax_mean);
    title(sprintf('#%02d',i))
    axis image
end
[axh,th]=watermark(sprintf('%s : unconditional simulation',alg));
set(th,'interpreter','none');
print('-dpdf',sprintf('sgems_demo_%s_uncond',alg))

figure;set_paper('landscape')
for i=1:S.XML.parameters.Nb_Realizations.value
    subplot(nsp,nsp,i);
    %pcolor(Sc.x,Sc.y,Sc.D(:,:,1,i)');shading interp;
    imagesc(Sc.x,Sc.y,Sc.D(:,:,1,i)');
    hold on;
    scatter(Sc.d_obs(:,1),Sc.d_obs(:,2),30,Sc.d_obs(:,4),'w','filled');
    scatter(Sc.d_obs(:,1),Sc.d_obs(:,2),15,Sc.d_obs(:,4),'filled');
    hold off;
    caxis(cax_mean)
    title(sprintf('#%02d',i))
    axis image
end
[axh,th]=watermark(sprintf('%s : conditional simulation',alg));
set(th,'interpreter','none');
print('-dpdf',sprintf('sgems_demo_%s_cond',alg))


figure;set_paper('landscape')
[em,ev]=etype(S.D);
subplot(2,2,1);
imagesc(S.x,S.y,em');colorbar;axis image;caxis(cax_mean)
title('E-type mean ')
subplot(2,2,2);
imagesc(S.x,S.y,ev');colorbar;axis image;;caxis(cax_var)
title('E-type variance')

[em_c,ev_c]=etype(Sc.D);
subplot(2,2,3);
imagesc(S.x,S.y,em_c');colorbar;axis image;caxis(cax_mean)
hold on;scatter(Sc.d_obs(:,1),Sc.d_obs(:,2),30,Sc.d_obs(:,4),'w','filled');hold off;
title('E-type mean (conditional)')
subplot(2,2,4);
imagesc(S.x,S.y,ev_c');colorbar;axis image;;caxis(cax_var)
hold on;scatter(Sc.d_obs(:,1),Sc.d_obs(:,2),30,Sc.d_obs(:,4),'w','filled');hold off;
title('E-type variance (conditional)')

[axh,th]=watermark(sprintf('%s : etype',alg));
set(th,'interpreter','none')
print('-dpdf',sprintf('sgems_demo_%s_etype',alg))


