%function sgems_read(file)

MN=1.561792946e+9; %c30=c
fclose all;
file='test3_3.sgems';
file='grid_30_30.sgems';
fid=fopen(file,'r');


O.magic_number = fread(fid,1,'uint32');

if (O.magic_number==MN)
    mgstat_verbose(sprintf('%s : OK S-GeMS format for %s',mfilename,file))
else
    mgstat_verbose(sprintf('%s : WRONG S-GeMS format for %s',mfilename,file))
    return
end

pos1=ftell(fid);



nc=60;
c = fread(fid,nc,'char')';


ichar=find(c>32);
ichar_sep=find(diff(ichar)>1);

O.name=char(c(ichar(1:ichar_sep(1))));



i1=ichar(ichar_sep+1);
try
    i2=ichar(ichar_sep(2));
catch
    i2=length(ichar)
end
O.tag=char(c(i1:i2));


% GO TO THE PROPER LOCATION
nspace=4; % 4 spaces after name;
fseek(fid,pos1+i2+4,'bof');
%c2 = fread(fid,9,'char')'

%% VERSION

O.version = fread(fid,1,'int32')';

if (O.version<100)
    mgstat_verbose(sprintf('%s : file too old (%s)',mfilename,file),10)
    return
end

O.n = fread(fid,3,'uint32')';
O.size = fread(fid,3,'float')';
O.origin = fread(fid,3,'float')';


pos2=ftell(fid);
c = fread(fid,nc,'char')';
ichar=find(c>32);
ichar_sep=find(diff(ichar)>1);
i1=ichar(1);
i2=ichar(ichar_sep(2));
O.tagname=char(c(i1:i2));
fseek(fid,pos2+i2-2,'bof');
fseek(fid,-9*4-3,'eof');
%fseek(fid,0,'bof');


%c = fread(fid,4,'uint32')'

f = fread(fid,Inf,'float')'

%% CLOSE FILE HANDLES
O

%fclose(fid);