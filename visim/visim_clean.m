% visim_clean : Removes debug files from harddisk
%
%
function visim_clean(V)
    
    if nargin==0
        files=dir('*.par');
        
        for i=1:length(files)
            V=read_visim(files(i).name);
            delete(['*_',V.out.fname])            
        end
        
    else
        if ~struct(V)
            V=read_visim(V);
        end
            
        delete(['*_',V.out.fname])
    end

    delete('fort.59');
    delete('fort.1');
    
    
    

