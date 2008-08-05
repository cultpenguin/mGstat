function sgems_clean(cwd)

if nargin==0
    cwd=pwd;
end
i=0;
i=i+1;F{i}='sgems_history.log';
i=i+1;F{i}='sgems_status.log';

for i=1:length(F);
    f=[cwd,filesep,F{i}];
    if exist(f,'file')
        delete(f)
    end
end
  
