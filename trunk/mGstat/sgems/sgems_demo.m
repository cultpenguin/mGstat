% sgems_demo : testing various SGeMS algorithms available from mGstat 
%
% Call : 
%
%   [S,Sc,t] = sgems_demo(alg,dim,nsim);
%   S=sgems_demo('sgsim');
%   S=sgems_demo('lusim');
%   S=sgems_demo('dssim');
%   S=sgems_demo('snesim_std');
%
% To run the test on all available algorithms use :
%   sgems_test;
%
% A calculation time of -1 indicates that the demo could
%   not be run
% 
%

%
%                                        Dell    Dual
%                                      laptop  workst 
%  sgsim     , sgems-wine ubuntu 8.10 :  5.0s    2.5s 
%  lusim     , sgems-wine ubuntu 8.10 :  8.1s    4.4s
%  snesim_std, sgems-wine ubuntu 8.10 : 87.2s   47.0s
%
%  sgsim     , sgems XP :                2.8s    1.7s
%  lusim     , sgems XP :                6.1s    3.7s
%  snesim_std, sgems XP :               68.0s   41.0s
%
function [S,Sc,t]=sgems_demo(alg,dim,nsim);
 
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

echo on;

if nargin<2
    dim.nx=50;
    dim.ny=30;
    dim.nz=1;
end
if nargin<3
    nsim=9;
end

mgstat_verbose(sprintf('%s : Testing SGeMS algorithm ''%s''',mfilename,alg),10);

S=sgems_get_par(alg);
S.XML.parameters.Nb_Realizations.value=nsim;
S.dim=dim;

%%
% UNCONDITIONAL SIMULATION!!!
S=sgems_grid(S);
%%
% CONDITIONAL SIMULATION!!!
Sc=S;

% conditional data

header{1}='X';header{2}='Y';header{3}='Z';
header{4}='DATA';
d_obs=[10,10,0,1;15,10,0,1;20,10,0,1; 10,22,0,1;15,22,0,1;20,22,0,1; 40 13 0 1; 40 2 0 0 ; 40 18 0 0 ; 10 2 0 0; 10 18 0 0 ];
Sc.f_obs='obs.sgems';

O=sgems_write_pointset(Sc.f_obs,d_obs,header,'OBS');
Sc.d_obs=d_obs;

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
colormap(1-gray)
print('-dpng',sprintf('sgems_demo_%s_uncond',alg))

figure;
set_paper('landscape')
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
colormap(1-gray)
print('-dpng',sprintf('sgems_demo_%s_cond',alg))


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
print('-dpng',sprintf('sgems_demo_%s_etype',alg))


echo off
