data(ln_zinc): 'zinc.eas', x=1, y=2, v=3, log, sk_mean=5.900000e+00, max=20;
variogram(ln_zinc):   0.05540000 Nug(0) +  0.58100000 Sph(900);
mask: 'mask_map';
method: gs;
predictions(ln_zinc): 'lzn_cspr';
set nsim = 2;
set mv = '-999';
