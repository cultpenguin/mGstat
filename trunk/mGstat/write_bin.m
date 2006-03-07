%write_bin.m 
%
% CALL : 
%   write_bin(filename,variable);

function write_bin(filename,variable);

fwriteid=fopen(filename,'w');
count=fwrite(fwriteid,variable,'float32');
fclose(fwriteid);
