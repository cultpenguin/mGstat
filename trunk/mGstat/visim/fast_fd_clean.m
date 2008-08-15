% fast_fd_clean : deletes in/output files from fast_fd_2d


i=0;
i=i+1;F{i}='fd*.time*';
i=i+1;F{i}='fd*.calc'; 
i=i+1;F{i}='log.file';
i=i+1;F{i}='rec.*';
i=i+1;F{i}='f.in';
i=i+1;F{i}='nowrite';
i=i+1;F{i}='vel.mod';
i=i+1;F{i}='current.iteration';
i=i+1;F{i}='for.header';
i=i+1;F{i}='fort.51';

for i=1:length(F);
    d=dir(F{i});
    if length(d)>0
        delete(F{i});
    end
end