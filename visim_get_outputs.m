function O=visim_get_outputs(V,do_plot);
[p,f]=fileparts(V.parfile);

if nargin<2
    do_plot=1;
end
nanval=-1e+8;
O.null='';

i=0;
i=i+1;FIL{i}='cv2v';form{i}='float64';
i=i+1;FIL{i}='cd2v';form{i}='float64';
i=i+1;FIL{i}='lambda';form{i}='float64';
i=i+1;FIL{i}='randpath';form{i}='float32';
i=i+1;FIL{i}='volnh';form{i}='float32';
i=i+1;FIL{i}='nh';form{i}='float32';


for i=1:length(FIL)

    try
        file=sprintf('%s_%s.out',FIL{i},f);
        O.(FIL{i})=f77strip(file,form{i});
        O.(FIL{i})(find(O.(FIL{i})==nanval))=NaN;
        if do_plot==1;
            set_paper('landscape');
            subplot(2,2,i);imagesc(O.(FIL{i}));
            title(FIL{i})
        end
    catch
        mgstat_verbose(sprintf('%s : failed to load %s',mfilename,file),10);
    end

end