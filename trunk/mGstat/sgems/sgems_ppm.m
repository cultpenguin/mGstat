% sgems_ppm : Probability pertubation
%
% Example : 
%   S=sgems_get_par('snesim_std');
%   S.XML.parameters.Nb_Realizations.value=1;
%   S=sgems_grid(S);
%   S_1=sgems_ppm(S,.1);
%   S_2=sgems_ppm(S,.5);
%   S_3=sgems_ppm(S,1);
function S=sgems_ppm(S,O,r);

if nargin==0
    
    help(mfilename)
    
    str=input('Do you want to see an example of PPMM ? [''Y''/N] ','s');
    if strcmp(upper(str),'Y')            
        S=sgems_get_par('snesim_std');
        S.XML.parameters.Nb_Realizations.value=1;
        S=sgems_grid(S);
        r_arr=[.1 .5];
        for i=1:length(r_arr)
            Sppm{i}=sgems_ppm(S,S.O,r_arr(i));
            subplot(2,2,i);
            imagesc(S.x,S.y,Sppm{i}.D');axis image;
            title(r_arr(i))
        end
    end
    return
end

if isstr(O)
    O=sgems_read(O);
end

O.grid_name='PROB';
S.XML.parameters.Seed.value=S.XML.parameters.Seed.value+1;
tau=r;
for ig=1:S.XML.parameters.Nb_Facies.value
    O.property{ig}=sprintf('F%d',ig-1);
        
    marg_pdf=S.XML.parameters.Marginal_Cdf.value(ig);
    
    d=(1-tau).*(O.data(1,:)==(ig-1))+tau.*marg_pdf;
    O.n_prop=length(O.property{ig}); % update
    O.data(ig,:)=d;
end
S.f_probfield=sprintf('prob_%d.sgems',round(tau*100));
sgems_write(S.f_probfield,O);

S=sgems_grid(S);


