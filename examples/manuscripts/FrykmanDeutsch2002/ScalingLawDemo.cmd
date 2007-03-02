data(test): dummy, sk_mean=25, max=100;
data(): 'ScalingLawDemo.eas', x=1;
variogram(test):   3.60000000 Sph(0.54);
set output = 'ScalingLawDemo.out.out';
set mv = 'NaN';
set format = '%12.8f';
set seed = 12;
method: gs;
