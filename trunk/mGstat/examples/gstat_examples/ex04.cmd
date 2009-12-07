data(zinc): 'zinc.eas', x=1, y=2, v=3, min=20, max=40, radius=1000;
data(): 'locs.eas', x=1, y=2;
variogram(zinc):   4.00000000 Nug(0) +  5.00000000 Sph(800);
blocksize: dx=40, dy=40;
set output = 'zincok.out';
set mv = '-999';
