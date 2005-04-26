% read_gstat_par : Reads gstat.par file into Matlab data structure
%
%
% KNOWN BUGS (FEB 2004)
%   Cannot load covariogram : covariogram(data1,data2)
%   Semivariogram line : Can only contain veriogram, not filename
%
function G=read_gstat_par(filename);

  if nargin==0,
    G=[];
    help read_gstat_par
    return;
  end
  
  if exist(filename)==0,
    G=[];
    mgstat_verbose(sprintf('%s : ''%s'' does not exist -> exiting',mfilename,filename),0);
    return;
  end
  
  v=3;
  
  G.mgstat.parfile=filename;
    
  fid=fopen(filename,'r');
  
  il=0;icomment=0;
  while (~feof(fid))
    il=il+1;
    
    % READ LINE AND STRIP LEADING AND TRAILING SPACES
    cline=strip_space(fgetl(fid));
    
    if length(cline)==0,
      cline(1)='#';
    end
    
    if cline(1)==char(35) % 35=#, THIS IS A COMMENT LINE
      icomment=icomment+1;
      G.mgstat.comment{icomment}=cline;
      mgstat_verbose(sprintf('Reading comment : %s',cline),10)
    else
      % SO, IT IS NOT A COMMENT LINE
      
      % CHECK THAT THE HOLE LINE IS READ (UNTIL ';')
      if isempty(find(cline==char(59)));
        % THIS IS A MULTILINE ENTRY
        MULcline{1}=cline;mul=1;
        while (isempty(find(cline==char(59))))
          cline=strip_comment(fgetl(fid));
          mul=mul+1;
          MULcline{mul}=cline;
        end
        cline=MULcline{1};
        for imul=2:mul          
          cline=[cline,MULcline{imul}];
        end
        mgstat_verbose(sprintf('MULTILINE READ : %s',cline),10)
      end
      % ENTRY IS NOW IN ONE LINE !


      sep=find(cline==':'); % location of colon seperator
      
      
      % SPLIT LINE INTO COMMAND AND DATA
      [cmd,data]=strip_command(cline(1:sep-1));        

      
      if isfield(G,cmd),
        icmd=length(G.(cmd))+1;
      else
        icmd=1;
      end
      
      if length(data)>0
        % IF DATA IS SET, ADD IT TO STRUCTURE
        G.(cmd){icmd}.data=data;
      end

      options=cline(sep+1:length(cline));      


      
      if isempty(sep)==1,
        % SET LINE
        [cmd,data]=deformat_set_entry(cline);
        if isfield(G,'set')==0,
          iset=1;
        else
          iset=length(G.set)+1;
        end
%        G.set{iset}.(cmd)=data;
        G.set.(cmd)=data;
        mgstat_verbose(sprintf('SET line %d : %s',iset,cline),10)
      elseif (strmatch(cmd,'variogram'))
        % GET VARIOGRAM....
        %if icmd==2, keyboard; end
        mgstat_verbose(sprintf('%s : Found variogram : %s',mfilename,options),10)
        G.(cmd){icmd}.V=deformat_variogram(options);
      else         % EXTRACT OPTIONS

        % mgstat_verbose(['********',cmd,' *******']);
        
        % if strmatch('mask',cmd),,end
        
        % remove comments
        options=strip_comment(options);
        %cstart=regexp(options,'#');
        %if ~isempty(cstart)
        %  options=options(1:cstart(1)-1);
        %end
        
        % remove semicolon
        options=regexprep(options,';','');  
        sep=find(options==',');

        if isempty(sep);
          isarray=1;
        else
          isarray=1:(length(sep)+1);
        end
        for is=isarray
          
          if (length(isarray)==1)
            is1=1;
            is2=length(options);
          else
            if is==1,
              is1=1;
              is2=sep(is)-1;
            elseif (is==(length(sep)+1))
              is1=sep(is-1)+1;
              is2=length(options);
            else            
              is1=sep(is-1)+1;
              is2=sep(is)-1;
            end
          end
          cop=options(is1:is2);
          cop=strip_space(cop);
          
          mgstat_verbose(sprintf('%s : cop="%s"',mfilename,cop),12)
          
          % mgstat_verbose(['--',cop])
          chkfile=find(cop==char(39));
          if isempty(chkfile);
            % OPTION IS NOT A FILENAME
             
            ieq=find(cop=='=');
            if isempty(ieq);
              varname=cop;
              varval='';
            else
              varname=cop(1:ieq-1);
              varval=cop(ieq+1:length(cop));
              % CONVERT TO NUMERICAL VALUE IF POSSIBLE
              if (~isempty(str2num(varval)))
                varval=str2num(varval);
              end
            end
            G.(cmd){icmd}.(varname)=varval;
          else
            % OPTION IS A FILENAME
            for ifile=1:(length(chkfile)./2)
              if ifile>1, mgstat_verbose(['MORE THAN ONE FILE ENTRY. NOT MPLEMENTED'])
              else
                in=(ifile-1)*2+1;
                filename=cop( chkfile(in)+1 : chkfile(in+1)-1 );
              end          
            end
            G.(cmd){icmd}.file=filename;            
          end

          

        
        end        
      end
      
    end
  end
    
  fclose(fid);
  
function [cmd,data]=strip_command(str)
  
  fstart=find(str=='(');
  fend=find(str==')');

  if isempty(fstart)
    cmd=str;
    data='';
  else
    cmd=str(1:fstart-1);
    data=str(fstart+1:fend-1);
  end
    

  
function [cmd,data]=deformat_set_entry(cline)
  
  cline=regexprep(cline,'set','');
  cline=strip_comment(cline);
  cline=regexprep(cline,';','');  
  cline=strip_space(cline);

  feq=find(cline=='=');
  cmd=strip_space(cline(1:feq-1));
  data=strip_space(cline(feq+1:length(cline)));
  
  if str2num(data)
    data=str2num(data);
    mgstat_verbose(sprintf('SET DEFORMAT : cmd="%s" data=%5.1g',cmd,data));
  else    
    if data(1)=='''';
      data=data(2:length(data)-1);
    end 
    mgstat_verbose(sprintf('SET DEFORMAT : cmd="%s" data="%s" ',cmd,data));
  end
    

  
function txt=strip_comment(txt)
  cstart=regexp(txt,'#');
  if ~isempty(cstart)
    txt=txt(1:cstart(1)-1);
  end
  