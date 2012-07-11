function max_r=semivar_get_max_range(Va);

if isstr(Va);
    Va=deformat_variogram(Va);
end

max_r=0;
for i=1:length(Va);
   max_r=max([max_r Va(i).par2(1)]);
end

