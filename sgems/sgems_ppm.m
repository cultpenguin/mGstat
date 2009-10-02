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
function S=sgems_ppm(S,O,r);

if nargin==0
    
    help(mfilename)
    
    str=input('Do you want to see an example of PPM ? [''Y''/N] ','s');

    if strcmp(upper(str),'Y')            
        sgems_example_ppm
    end
    return
end

if isstr(O)
    O=sgems_read(O);
end


O.grid_name='PROB';
S.XML.parameters.Seed.value=S.XML.parameters.Seed.value+1;
tau=r;
data=O.data(:,1);
for ig=1:S.XML.parameters.Nb_Facies.value

    O.property{ig}=sprintf('F%d',ig-1);
        
    marg_pdf=S.XML.parameters.Marginal_Cdf.value(ig);
    d=data.*0;
    ii{ig}=find(data==(ig-1));
    d(ii{ig})=1;
    p_facies=(1-tau).*d+tau.*marg_pdf;
    %p_facies=(1-tau).*[O.data(1,:)==(ig-1)]+tau.*marg_pdf
    O.data(:,ig)=p_facies;
    O.n_prop=length(O.property{ig}); % update
end
S.f_probfield=sprintf('prob_%d.sgems',round(tau*100));

sgems_write(S.f_probfield,O);

S=sgems_grid(S);


