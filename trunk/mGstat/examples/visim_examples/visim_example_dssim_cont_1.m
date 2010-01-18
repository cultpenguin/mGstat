V=visim_init(1:1:61,1:1:61);
V.parfile='visim_example_dssim_cont_1.par
d1=randn(1,2000)*sqrt(.2)+8;
d2=randn(1,1200)*sqrt(.1)+10;
d3=randn(1,2800)*sqrt(.1)+13;
d_target=[d1,d2,d3]';
V.refhist.fname='dssim_target.eas';
write_eas(V.refhist.fname,d_target); % write target distribution
V.ccdf=1;                 % use DSSIM
V.refhist.do_discrete=0;  % Assume continious target histogram
V.nsim=10;
V=visim_init(V); 
V.Va.it=3;     % Choose Gaussian semivariogram
V.Va.a_hmax=15; % correlation length (direction of max continuity)
V.Va.a_hmin=15; % correlation length (direction of min continuity)
V=visim(V);
figure(1);visim_plot_sim(V);
print_mul('visim_example_dssim_cont_sim');
figure(2);visim_plot_hist(V);
print_mul('visim_example_dssim_cont_hist');

