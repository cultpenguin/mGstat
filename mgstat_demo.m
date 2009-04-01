% mgstat_demo : demos illustrating the use of mGstat
%
% Try some of the following demos:
%
% mgstat_demo('mgstat'); % mgstat demo, illustrating the native matlab
%                        %  algorithms
% mgstat_demo('gstat');  % demos using gstat
% mgstat_demo('visim');  % demos using visim
% mgstat_demo('sgems');  % demos using sgems
% mgstat_demo('snesim'); % demos using snesim
%
% mgstat_demo('all'); % runs all of the available demos.
%

function mgstat_demo(method);

% CHECK IF JURA DATA IS AVAILABLE
    data_dir=[mgstat_dir,filesep,'examples',filesep,'data'];
if ~exist([data_dir,filesep,'prediction.dat'],'file')
    jura_url='http://gooveaerts.com/';
    CHOICE=input(sprintf('DOWNLOAD JURA DATA FROM GOOVAERTS SITE (GOOVAERTS) ? (Y/N) ',jura_url),'s');
    if strcmp(lower(CHOICE),'y')
        
        mgstat_verbose(sprintf('%s : loadiing JURA data 1/3',mfilename),11);
        p = urlread('http://home.comcast.net/~pgoovaerts/prediction.dat');   
        p_id=fopen([data_dir,filesep,'prediction.dat'],'w');
        fprintf(p_id,'%s',p);
        fclose(p_id);
        
        mgstat_verbose(sprintf('%s : loadiing JURA data 2/3',mfilename),11);
        v = urlread('http://home.comcast.net/~pgoovaerts/validation.dat');
        v_id=fopen([data_dir,filesep,'validation.dat'],'w');
        fprintf(v_id,'%s',v);
        fclose(v_id);

        mgstat_verbose(sprintf('%s : loadiing JURA data 3/3',mfilename),11);
        t = urlread('http://home.comcast.net/~pgoovaerts/transect.dat');
        t_id=fopen([data_dir,filesep,'transect.dat'],'w');
        fprintf(t_id,'%s',t);
        fclose(t_id);
    end
end
        
if nargin==0
    help mgstat_demo,
    return
end

if strcmp(method,'all');
    mgstat_demo('visim')
    mgstat_demo('sgems')
    return
end


switch lower(method)
    case('mgstat')
        disp(method)
        addpath([mgstat_dir,filesep,'examples',filesep,'mgstat_examples'])
        mgstat_ex_krig_1d;
        
    case('visim')
        disp(method)
    case('sgems')
        disp(method)
        
        m=sgems_get_par;
        for i=1:length(m);
            if ~strcmp(m{i},'.svn')
                disp(sprintf('sGems algorithm ''%s'' (hit key to start)',m{i}));
                pause
                try 
                    echo on
                    sgems_demo(m{i});
                    echo off
                catch
                    disp(sprintf('sGems algorithm ''%s'' FAILED',m{i}));
                    pause(1)
                end
            end
        end
        % sgsim
        
        
end


echo off
