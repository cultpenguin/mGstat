% mgstat_binary : returns the path to the binary gstat
function gstat=mgstat_binary;
  % gstat='/home/tmh/RESEARCH/PROGRAMMING/mGstat/gstat/gstat';
  % gstat='c:\thomas\Programming\mGstat\gstat.exe';
  gstat='';
    
  if isempty(gstat)  
    if isunix
      [s,w]=system('which gstat');
      
      
      if isempty(w),
        [p,f,s]=fileparts(which('mgstat'));
        gstat=fullfile(p,'gstat');            
      else
        gstat=w(1:length(w)-1);
      end
    else 
      [p,f,s]=fileparts(which('mgstat'));
      if isempty(p),
        gstat='gstat.exe';
      else
        gstat=fullfile(p,'gstat.exe');
      end
    end
    
    if exist(gstat)==0, 
      gstat='';
    end
  end
  
 % gstat='/home/tmh/RESEARCH/PROGRAMMING/mGstat/gstat/gstat';
  
  if isempty(gstat)  
    mgstat_verbose(sprintf('COULD NOT FIND GSTAT EXECUTABLE !! edit -> %s',mfilename),-1);
    gstat='';
    return;
  end
  