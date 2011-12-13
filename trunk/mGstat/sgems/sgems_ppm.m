% sgems_ppm : Probability perturbation
%
% Example : 
%        S=sgems_get_par('snesim_std');
%        S.XML.parameters.Nb_Realizations.value=1;
%        S=sgems_grid(S);
%        r_arr=linspace(0.1,1,25);
%        for i=1:length(r_arr)
%            Sppm{i}=sgems_ppm(S,S.O,r_arr(i));
%            subplot(5,5,i);
%            imagesc(S.x,S.y,Sppm{i}.D');axis image;
%            title(r_arr(i))
%            drawnow;
%        end
function [S,O]=sgems_ppm(S,r,O);

if nargin==0
    
    help(mfilename)
    
    str=input('Do you want to see an example of PPM ? [''Y''/N] ','s');

    if strcmp(upper(str),'Y')        
        %% ADD PATH TO SGEMS EXAMPLES
        addpath(sprintf('%s%sexamples%ssgems_examples',mgstat_dir,filesep,filesep));
        sgems_example_ppm;
    end
    return
end

if nargin<3
    try
        O=S.O;
    catch
        disp(sprintf('%s : Missing data structure for PPM',mfilename));
    end
end


if isstr(O)
    O=sgems_read(O);
end

figure_focus(12);clf

O.grid_name='PROB';
S.XML.parameters.Seed.value=S.XML.parameters.Seed.value+1;

data=O.data(:,1);
for ig=1:S.XML.parameters.Nb_Facies.value

    O.property{ig}=sprintf('F%d',ig-1);
        
    marg_pdf=S.XML.parameters.Marginal_Cdf.value(ig);
    d=data.*0;
    ii{ig}=find(data==(ig-1));
    d(ii{ig})=1;
    p_facies=(1-r).*d+r.*marg_pdf;
    %p_facies=(1-r).*[O.data(1,:)==(ig-1)]+r.*marg_pdf
    O.data(:,ig)=p_facies;
    O.n_prop=length(O.property{ig}); % update
    
    figure_focus(12);
    subplot(2,S.XML.parameters.Nb_Facies.value,ig)
    imagesc(reshape(p_facies,S.dim.nx,S.dim.ny)')
    %imagesc(p_facies);
    axis image;caxis([0 1]);colorbar
    colormap(1-gray)
    title(sprintf('Prob(Facies=%d)',ig-1))
    drawnow;
end
S.f_probfield=sprintf('prob_%d.sgems',round(r*100));

sgems_write(S.f_probfield,O);

S=sgems_grid(S);

figure_focus(12);
subplot(2,1,2);
imagesc(S.x,S.y,S.D');axis image
title(sprintf('PPM using r=%g',r))
