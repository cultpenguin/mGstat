% visim_clean : Removes debug files from harddisk
%
%
% visim_clean : removes all debug files related to '*.par' VISIM files
% visim_clean('visim.par') : removes all debug files 
%                            related to  the 'visim.par' VISIM files
% visim_clean('visim.par',1) : removes all debug files
%                            from related to visim.par' AND visim.out 
%
%
function visim_clean(V,del_out)
    
    fclose all;

    if nargin<2
        del_out=1;
    end

    
    if nargin==0
        files=dir('*.par');
        
        for i=1:length(files)
            %V=read_visim(files(i).name);
            %delete(['*_',V.out.fname])            
            files(i).name;
            visim_clean(files(i).name,del_out);
        end
        
    else
        try;mgstat_verbose(sprintf('Deleting ''%s''',V),10);end
        try
            if ~isstruct(V)
                V=read_visim(V);
            end
      
            try
                [p,f]=fileparts(V);
                delete(sprintf('%s_mask.out',f));
            end
            
            if isfield(V,'out')
                delete(['*',V.out.fname])
            end
        catch
            if ~isstruct(V)
                %disp(sprintf('Could not read/clean %s',V))
            else
                disp(sprintf('Could not read/clean %s',V.parfile))
            end
            return
        end
    end
    
    delete('fort.*');
    
    
    
    if nargin==2
        if ((del_out==1)&(isfield(V,'out'))),
            if exist('V.out.fname','file')
                delete([V.out.fname])            
            end
        end
    end
    
    
    

