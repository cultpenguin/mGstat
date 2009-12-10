#
# Multiple Kriging: Prediction of more than one variable
#
data(ln_zinc): 'zincmap.eas', x=1, y=2, v=3, log, min=20, max=40, radius=1000;
data(sq_dist): 'zincmap.eas', x=1, y=2, v=4, min=20, max=40, radius=1000;
variogram(ln_zinc):   0.05540000 Nug(0) +  0.58100000 Sph(900);
variogram(sq_dist):   0.06310000 Sph(900);
mask: 'mask_map';
predictions(ln_zinc): 'lzn_okpr';
predictions(sq_dist): 'sqd_okpr';
variances(ln_zinc): 'lzn_okvr';
variances(sq_dist): 'sqd_okvr';
