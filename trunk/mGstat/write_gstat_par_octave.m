% write_gstat_par : write gstat.par file from Matlab structure
% 
% CALL :
%
%    filename=write_gstat_par(G,filename);
%
%  input --:
%  G [struct]: gstat matlab structure
%  filename [string] : optinal filename
%
%  output --:
%  filename [string] : filename of command file written to disk 
%

function filename=write_gstat_par_octave(G,filename)
    if nargin==0,
        help write_gstat_par
    end
  
  
  if isfield(G,'mgstat');
    if ~isfield(G.mgstat,'parfile')
      G.mgstat.parfile='gstat.cmd';
    end
  else
    G.mgstat.parfile='gstat.cmd';
  end
  
  if nargin==2, G.mgstat.parfile=filename; end
  
  filename=G.mgstat.parfile;

  mgstat_verbose(sprintf('Writing gstat par file : %s',filename),5);
  
  fid=fopen(filename,'w');
  
  fn=fieldnames(G);
  
  for ifn=1:length(fn)
    
    if strcmp('mgstat',fn{ifn}),
      % COMMENTS
      if isfield(G.mgstat,'comment')
        nc=length(G.mgstat.comment);
        for i=1:nc
          fprintf(fid,'%s\n',G.mgstat.comment{i});
        end
      end
      
    elseif strcmp('variogram',fn{ifn}),
      % VARIOGRAM
      nv=length(G.variogram);
      for i=1:nv
        fprintf(fid,'variogram(%s): ',G.variogram(i).data);
        if isfield(G.variogram(i),'file')
          fprintf(fid,'''%s''',G.variogram(i).file);
          
          if (isfield(G.variogram(i),'V'))
            fprintf(fid, ', ');
          end
          
        end
        if isfield(G.variogram(i),'V')
          vartxt=format_variogram(G.variogram(i).V);
          fprintf(fid,' %s',vartxt);
        end
        fprintf(fid,';\n');
      end
      
    elseif strcmp('set',fn{ifn}),
      % SET
      df=fieldnames(G.set);
      n=length(df);
      for i=1:n;
        cmd=df{i};
        data=G.set(1).(df{i});
        if (isnumeric(data)&~strcmp(cmd,'mv'))
          if data==round(data)
            fprintf(fid,'set %s = %d;\n',cmd,data);
          else
            fprintf(fid,'set %s = %8.4f;\n',cmd,data);
          end
        else
          fprintf(fid,'set %s = ''%s'';\n',cmd,data);
        end
        
      end
      
    else
      % MISC
      fname=fn{ifn};
      n=length(G.(fname));
      
      
      for i=1:n
        if isfield(G.(fname)(i),'data'),
          fprintf(fid,'%s(%s): ',fname,G.(fname)(i).data);
          idf1=2;
        else
          if strcmp(fname,'data')
            % data(): requires empty () !
            fprintf(fid,'%s(): ',fname);
          else
            fprintf(fid,'%s: ',fname);
          end
          idf1=1;
        end
                
        
        df=fieldnames(G.(fname)(i));
        for idf=idf1:length(df);
          
          cmd=df{idf};
          data=G.(fname)(i).(cmd);
          
          % WE NEED TO DO MORE TO MAKE SURE THESE FOLLOWING LINES WORK IN
          % OCTAVE! ! ! ! ! !
          
          add_comma=1;
          if (isnumeric(data)&isempty(data))
              % DO NOTHING AS THIS IS AN EMPTY STRUCTURE
              add_comma=0;
          elseif (isstr(data)&(length(data)>0))
            % fprintf(fid,'%s=''%s''',cmd,data);
            fprintf(fid,'''%s''',data);
          elseif isnumeric(data)
            fprintf(fid,'%s=%d',cmd,data);
          elseif isempty(data)
            fprintf(fid,'%s',cmd);
          end
          
          if ((add_comma==1)&(~(idf==length(df))));
            fprintf(fid,', ');
          end
          
        end
        fprintf(fid,';\n');
      end
      
      
      
    end
    
  end
  
  
  fclose(fid);
