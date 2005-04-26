% mgstat_convert : convert between ascii/binary formats
%
%  CALL : [data,x,y,dx,nanval]=mgstat_convert(file,f,suf)
%
function [data,x,y,dx,nanval]=mgstat_convert(file,f,suf)

  data=[];x=[];y=[];dx=[];nanval=[];
  
  if nargin<1,
    help mgstat_convert
    return;
  end
  if nargin<2
    f='a';
    suf='.ascii';
  end
  
  if (exist(file)==0),
    mgstat_verbose(sprintf('file ''%s'' does not seem to exist :/',file),-1);
    return;
  end
  
  gstat=mgstat_binary;
	
	sysout=system([gstat,' -e convert -f ',f,' ',file,' ',file,suf]);

  if (nargout>0)&(f=='a');
    % [data,x,y,dx,nanval]=read_gstat_ascii([file,suf]);
    [data,x,y,dx,nanval]=read_arcinfo_ascii([file,suf]);
  end
