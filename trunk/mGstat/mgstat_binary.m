% mgstat_binary : returns the path to the binary gstat
function gstat=mgstat_binary;
  gstat='/home/tmh/RESEARCH/PROGRAMMING/mGstat/gstat/gstat';
  % gstat='';
  
  if isempty(gstat)  
    if isunix
      [s,w]=system('which gstat');
      gstat=w(1:length(w)-1);
    else 
      gstat='gstat.exe';
    end
    
    if exist(gstat)==0, 
      gstat='';
    end
  end
  
  if isempty(gstat)  
    mgstat_verbose(sprintf('COULD NOT FIND GSTAT EXECUTABLE !! edit -> %s',mfilename),-1);
    gstat='';
    return;
  end
  