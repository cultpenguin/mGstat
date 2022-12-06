% cummean: cumulative mean of series
function cd=cummean(d)
for i=1:length(d)
    cd(i)=mean(d(1:i));
end
