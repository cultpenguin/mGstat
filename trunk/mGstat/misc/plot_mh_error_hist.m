function plot_mh_error_hist(d_obs,d_est,Cd)

Cd=Cd(1);

xlim(1)=-5*sqrt(Cd);
xlim(2)=+5*sqrt(Cd);
x=linspace(xlim(1),xlim(2),80);

Cd_synth=normpdf(x,0,sqrt(Cd));

hx=hist(d_est-d_obs,x);
plot(x,Cd_synth./max(Cd_synth),'k-',x,hx./max(hx),'r-')



