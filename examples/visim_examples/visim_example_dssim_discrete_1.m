V=visim_init(1:1:61,1:1:61);
V.parfile='visim_example_dssim_discrete_1';
d_target=[1 10 10 40]';
V.refhist.fname='dssim_target_discrete.eas';
write_eas(V.refhist.fname,d_target); % write target distribution
V.ccdf=1;                 % use DSSIM
V.refhist.do_discrete=1;  % Assume continious target histogram
V.nsim=10;
V=visim_init(V); 
V.Va.it=3;     % Choose Gaussian semivariogram
V.Va.a_hmax=15; % correlation length (direction of max continuity)
V.Va.a_hmin=15; % correlation length (direction of min continuity)
V=visim(V);

figure(1);visim_plot_sim(V);
print_mul('visim_example_dssim_discrete_1_sim');
figure(2);visim_plot_hist(V);
print_mul('visim_example_dssim_discrete_1_hist');

