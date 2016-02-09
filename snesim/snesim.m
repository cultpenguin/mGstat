% snesim : runs snesim with parameter file or snesim structure
%
% Call : 
%   snesim('snesim.par');
%
%   S=read_snesim('snesim.par');
%   S.nsim=10;
%   snesim(S)
%
%   S=snesim_init;
%   S.nsim=10;
%   snesim(S)
%
%   %% 
%   S=snesim(S,1:1:10,1:1:10,1);
%
%
% Source code for SNESIM can be downloaded here:
% https://github.com/SCRFpublic/snesim-standalone
%
% executable files must be located in $MGSTAT_INSTALL/bin
% The default executable for windows is $MGSTAT_INSTALL/bin/snesim.exe
% The default executable for 64bit linux is $MGSTAT_INSTALL/bin/snesim_glnxa64
% The default executable for 64bit OSX is $MGSTAT_INSTALL/bin/snesim_maci64
%
% 
% OSX notes:
%   * Xocde must be installed
%   * The correct path for gfortran must be set. Usually this can be
%     obtained using setenv('DYLD_LIBRARY_PATH', '/usr/local/bin');
%
%
% See also snesim_init, read_snesim, write_snesim
%
%
function V=snesim(parfile,x,y,z)
  % FIRST TRY TO FIND THE snesim BINARY IN THE mGstat/bin/ DIRECTORY
  [p,f,s]=fileparts(which('mgstat_verbose'));
  mgstat_bin_dir=[p,filesep,'bin'];
  if isunix==1
      snesim_bin=[mgstat_bin_dir,filesep,'snesim_',computer('arch')];
      if ~exist(snesim_bin,'file')
          snesim_bin=[mgstat_bin_dir,filesep,'snesim'];
      end
      
      if ismac
          if isempty(getenv('DYLD_LIBRARY_PATH'))
              
              disp(sprintf('%s: SETTING DYLD LIBRARY PATH',mfilename))
              setenv('DYLD_LIBRARY_PATH', '/usr/local/bin')
          else
              if (~strcmp(getenv('DYLD_LIBRARY_PATH'),'/usr/local/bin'))
                   % setenv('DYLD_LIBRARY_PATH',['/usr/local/bin:',getenv('DYLD_LIBRARY_PATH')]);              
                   setenv('DYLD_LIBRARY_PATH',['/usr/local/bin:']);              
              end   
          end
         
      end      
  else
      snesim_bin=sprintf('%s\\bin\\snesim.exe',p);
  end

 % TO MANUALLY SET THE PATH TO snesim PUT IT HERE :
 % snesim_bin='/scratch/tmh/RESEARCH/PROGRAMMING/GSLIB/snesim/snesim';

  if (exist(snesim_bin,'file'))==0
    disp(sprintf('COULD NOT FIND snesim binary : %s',snesim_bin));
  end

  if ((nargin==0)&&(nargout==0))
    disp(sprintf('Using snesim binary : %s',snesim_bin));
    return
  end	
  
  if isstruct(parfile);
      
      S=parfile;
      if nargin>1
          S.nx=length(x);
          S.xmn=x(1);
          S.xsiz=x(2)-x(1);
          S.x=x;
      end
      if nargin>2
          S.ny=length(y);
          S.ymn=y(1);
          S.ysiz=y(2)-y(1);
          S.y=y;
      end
      if nargin>3
          S.nz=length(z);
          S.zmn=z(1);
          if S.nz==1,
            S.zsiz=1;
          else
            S.zsiz=z(2)-z(1);
          end
          S.z=z;
      end
      
      write_snesim(S);
      parfile=S.parfile;
  end
  tic
    
  
  
if isunix==1
    [status,result]=system(sprintf('%s < %s',snesim_bin,parfile));
else
    [status,result]=system(sprintf('"%s" < %s',snesim_bin,parfile));
end
%V=read_visim(parfile);
%V.time=toc;
mgstat_verbose(sprintf('%s : %s',mfilename,result),1);

  
%  if isunix==1
%      cmd=sprintf('%s < %s',snesim_bin,parfile);
%      unix(cmd);
%  else
%      cmd=sprintf('"%s" < %s',snesim_bin,parfile);
%      dos(cmd);
%  end
  V=read_snesim(parfile,1);
  V.time=toc;
  
  
  fclose all;
  
  
