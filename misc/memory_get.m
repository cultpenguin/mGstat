function [mem_total,mem_used,mem_available]=memory_get();
% memory_get: Get memory inforation on Unix and Windows systems
%
% Call: 
%    [mem_total,mem_used,mem_available]=memory_get;
% 
%
mem_total=[];
mem_used=[];
mem_available=[];
if isunix
    [r,w] = unix('free | grep Mem');
    ws=split(w);
    mem_total=str2num(ws{2})/1e+6;
    mem_used=str2num(ws{3})/1e+6;
    mem_available=str2num(ws{4})/1e+6;
else 
    [USERVIEW, SYSTEMVIEW] = memory;
    mem_total=SYSTEMVIEW.PhysicalMemory.Total/1024/1E+6;
    mem_available=SYSTEMVIEW.PhysicalMemory.Available/1024/1E+6;
    mem_used=mem_total-mem_available;
end