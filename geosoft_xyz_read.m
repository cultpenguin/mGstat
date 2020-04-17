% geosoft_xyz_read: reads Geosoft XYZ ASCII data format
% Call
%
%   % column header in line 2, and no strings in data section
%   [D,LINE,CHEAD,HEADER]=geosoft_xyz_read(filename);
%
%   % column header in line 5, and no strings in data section
%   chead_line=5;
%   [D,LINE,CHEAD,HEADER]=geosoft_xyz_read(filename,chead_line);
%
%   % column header in line 5, and possible strings in data section 
%   chead_line=5;
%   lookfor_strings=1; %(SLOW)
%   [D,LINE,CHEAD,HEADER]=geosoft_xyz_read(filename,chead_line,no_strings);
%
%
%
function [D,LINE,CHEAD,HEADER]=geosoft_xyz_read(filename,chead_line,lookfor_strings);
if nargin<1;
    filename='YukonAEM_INV.XYZ';
end
if nargin<2;
    chead_line=2;
    disp(sprintf('%s: Assuming column header in line %d',mfilename,chead_line));
end
if nargin<3;
    lookfor_strings=0;
    disp(sprintf('%s: Assuming there are no strings in data!!',mfilename));
end


CHEAD=[];
disp(sprintf('%s: Reading %s',mfilename,filename))
fid=fopen(filename,'r');


NC=100;
NL=28;
IC_X=1;
IC_Y=2;
IC_ELEV=3;
IC_SKIP=4;

IC_BOT=IC_SKIP+[1:NL];
IC_TOP=IC_SKIP+NL+[1:NL];
IC_RES=IC_SKIP+2*NL+[1:NL];

%USE_LINES=10142;
USE_LINES='';;
USELINE=0;
iline=0;
iheader=0;
line_in_file=0;
while ~feof(fid);
    line_in_file=line_in_file+1;
    l=fgetl(fid);
    if strcmp(lower(l(1)),'/');
        % COMMENT OR HEADER
        is_header=0;
        if length(l)==1; 
            is_header=1;
        else
            if strcmp(lower(l(2)),'/')
                is_header=0; % is_comment=1;
            else
                is_header=1;
            end
        end
        if is_header==1
            disp(sprintf('%s: Reading header line %d: ',mfilename,iheader+1,l));
            iheader=iheader+1;
            HEADER{iheader}=l;
            if (iheader==chead_line);
                CHEAD=strsplit(strtrim(l(2:end)));
            end
        else
            disp(sprintf('%s: Skipping line %d: ',mfilename,i,l));
        end
        
    elseif (~strcmp(l(1),' '));%(isempty(str2num(l(1)))); %strcmp(lower(l(1:4)),'line');
        
        LINENUMBER=str2num(l(5:end));
        if line_in_file==12, keyboard;end
        if ((~isempty(find(LINENUMBER==USE_LINES)))|(length(USE_LINES)==0));
            USELINE=1;
            disp(sprintf('reading line : %d',LINENUMBER));;        
            iline=iline+1;
            LINE(iline)=LINENUMBER;
        
        else
            USELINE=0;
            disp(sprintf('skipping line : %d',LINENUMBER));;        
        end
        
        idata=0;
        
    elseif (USELINE==1);
        % ACTUAL DATA
        idata=idata+1;
        if lookfor_strings==0;
            % assume no strings in data section
            linedata=sscanf(l,'%f');
        else
            % possible strings in data sections (much slower)
            line_split=strsplit(strtrim(l));
            for k=1:length(line_split);
                linedata(k)=str2num(line_split{k});
            end
        end
        
%         if idata==1;
%             BOT=linedata(IC_BOT);
%             TOP=linedata(IC_TOP);           
%         end
%         n_linedata=length(linedata);
%         RES=linedata(IC_RES(1):end);
%         D{iline}.RES(1:NL,idata)=NaN;;
%         D{iline}.RES(1:length(RES),idata)=RES;
%         D{iline}.ELEV(idata)=linedata(IC_ELEV);
%         D{iline}.UTMX(idata)=linedata(IC_X);
%         D{iline}.UTMY(idata)=linedata(IC_Y);
%         %D{iline}(idata,1:n_linedata)=sscanf(l,'%f');

          try 
              D{iline}(idata,1:length(linedata))=linedata;
          catch
              keyboard
          end
    else
        keyboard
        % do nothin
    end
    
        
end


fclose(fid);
try
if nargout==0;
    [p,f,e]=fileparts(filename);
    if (length(USE_LINES)==1)
        f_out=sprintf('%s_%g',f,USE_LINES);
    else
        f_out=[f,'.mat'];
    end
    save(f_out,'D','LINE','TOP','BOT','H');
end
catch
    keyboard;
end