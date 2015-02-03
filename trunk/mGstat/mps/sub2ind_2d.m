function idx = sub2ind_2d(M, rows, cols);

idx = rows + (cols-1)*M(1);
