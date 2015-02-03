% shuffle: shuffle an array
function d_shuffled=shuffle(d)
ir=randomsample(length(d),length(d));
d_shuffled=d(ir);