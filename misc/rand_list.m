function [n,list]=rand_list(list,r)

%Call:[n,list]=rand_list(list,r)
% r=0 random
% r=1 systematic (raster scan manner)

if nargin<2
    r=0;
end

if r==0
    num=round(rand*(length(list)-1))+1;
    n=list(num);
    list(num)=NaN;
    list_tmp=list(find(~isnan(list)));
    clear list
    list=list_tmp;
    clear list_tmp
elseif r==1
    n=list(1);
    list(1)=NaN;
    list_tmp=list(find(~isnan(list)));
    clear list
    list=list_tmp;
    clear list_tmp
end
