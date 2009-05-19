function options=visim_precal_linearization(V,S,R,t,t_err,m_ref,options,hmin_arr,hmax_arr);

if nargin<7,options.null='';end
if nargin<8,hmin_arr=[1:2:7];end
if nargin<9,hmax_arr=[1:2:7];end


for ihmin=1:length(hmin_arr)
    for ihmax=1:length(hmax_arr)
        VV{ihmin,ihmax}=V;
        VV{ihmin,ihmax}.Va.a_hmax=hmax_arr(ihmax);
        VV{ihmin,ihmax}.Va.a_hmin=hmin_arr(ihmin);
        %[VV{ihmin,ihmax},VVlsq{ihmin,ihmax}]=visim_tomography_linearize(VV{ihmin,ihmax},S,R,t,t_err,m_ref,options);
        [VV{ihmin,ihmax}]=visim_tomography_linearize(VV{ihmin,ihmax},S,R,t,t_err,m_ref,options);
    end
    save M_TEST
end

doPrint=0;
if doPrint==1
    for ihmin=1:length(hmin_arr)
        for ihmax=1:length(hmax_arr)
            figure(10);set_paper('landscape')
            subplot(length(hmin_arr),length(hmax_arr),(ihmin-1)*length(hmax_arr)+ihmax)
            set(gca,'FontSize',4);
            imagesc(V.x,V.y,VVlsq{ihmin,ihmax}{1}.etype.mean');axis image
            title(sprintf('hmin=%g hmax=%g',VV{ihmin,ihmax}.Va.a_hmin,VV{ihmin,ihmax}.Va.a_hmax))
            caxis([0.1 0.16])
            
            figure(11);set_paper('landscape')
            subplot(length(hmin_arr),length(hmax_arr),(ihmin-1)*length(hmax_arr)+ihmax)
            set(gca,'FontSize',4);
            visim_plot_kernel(VV{ihmin,ihmax});
            title(sprintf('hmin=%g hmax=%g',VV{ihmin,ihmax}.Va.a_hmin,VV{ihmin,ihmax}.Va.a_hmax))
            
            save PRECAL_TEST;
            
        end
    end
    
    try
        name=options.name;
    catch
        name='LIN';
    end
    
    %figure(10);print_mul([name,'_linearize_test_etypes']);
    %figure(11);print_mul([name,'_linearize_test_kernels']);
end


options.linearize.hmin_arr=hmin_arr;
options.linearize.hmax_arr=hmax_arr;
options.linearize.VV=VV;
%options.linearize.VVlsq=VVlsq;


