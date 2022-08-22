function [mem_total,mem_used,mem_available]=memory_get();
mem_total=[];
mem_used=[];
mem_available=[];
if isunix
    [r,w] = unix('free | grep Mem');
    ws=split(w);
    mem_total=str2num(ws{2})/1e+6;
    mem_used=str2num(ws{3})/1e+6;
    mem_available=str2num(ws{4})/1e+6;
else iswin==1
    [USERVIEW, SYSTEMVIEW] = memory;
    mem_total=USERVIEW.MaxPossibleArrayBytes/1024/1E+6;
end