% visim_clean : Removes debug files from harddisk
%
%
function visim_clean(V)
    
    delete(['*_',V.out.fname])
    

    
    

