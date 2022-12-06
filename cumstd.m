% cumstd: cumulative standard deviation of series
function cstd=cumstd(d)
for i=1:length(d)
    cstd(i)=std(d(1:i));
end
