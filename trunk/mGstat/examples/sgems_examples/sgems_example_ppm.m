% sgems_example_ppm
S=sgems_get_par('snesim_std');

dim.nx=130;
dim.ny=80;
dim.nz=1;
S.dim=dim;

S.XML.parameters.Seed.value=1;
S.XML.parameters.Nb_Realizations.value=1;
S=sgems_grid(S);
Sorg=S;

O=sgems_read('snesim_std.sgems');
O2=O;
O2.grid_name='PROB';

%for tau=linspace(0,1,21);
tau_arr=linspace(0.0,.3,21);
%tau_arr=0.9;
S.XML.parameters.Seed.value=S.XML.parameters.Seed.value+1;
for itau=1:length(tau_arr);
    tau=tau_arr(itau);
    for ig=1:S.XML.parameters.Nb_Facies.value
        O2.property{ig}=sprintf('F%d',ig-1);
        
        marg_pdf=S.XML.parameters.Marginal_Cdf.value(ig);
        
        d=(1-tau).*(O.data(1,:)==(ig-1))+tau.*marg_pdf;
        O2.n_prop=length(O2.property{ig}); % update 
        O2.data(ig,:)=d;
    end
    S.f_probfield=sprintf('prob_%d.sgems',round(tau*100));
    sgems_write(S.f_probfield,O2);
    
    S=sgems_grid(S);
    D(:,:,:,itau)=S.D(:,:,:,1);
    
    figure(1);clf,
    subplot(1,2,1);
    imagesc(S.x,S.y,Sorg.D(:,:,1)');axis image
    subplot(1,2,2);
    imagesc(S.x,S.y,S.D(:,:,1)');axis image
    drawnow;
    
    figure(2);
    for i=1:size(D,4);
        subplot(6,4,i);
        imagesc(S.x,S.y,D(:,:,:,i)');
        axis image;
        title(num2str(tau_arr(i)));
    end
    drawnow;
end
    
