% ScalingLawDemo.m
%
% Frykman, P. and Deutsch, C. V., 2002. Practical application 
%   of Geostatisgical Scaling Laws For Data Integration.
%   Pterophysics 42(3), 153-171;
%
%

% GIVE SCALES
scale_small=0.02;
if exist('scale_large')==0
  scale_large=0.5;
end


% Give data values
z=[0:scale_small:60]';
write_eas('ScalingLawDemo.eas',z(:),{'Z [m]'});

% Read gstat structure.
G=read_gstat_par('ScalingLawDemo.cmd');

% Set semivariogram model
V=deformat_variogram('3.6 Sph(0.54)');
G.variogram{1}.V=V;

% Set mean
G.data{1}.sk_mean=25;
G.data{1}.max=100;

% APPLY SCALING LAWS
Vb=V;
range_block=sum([V.par2])+(scale_large-scale_small);
Vb.par2=range_block;

n=10;i=0;
for r=linspace(0,scale_small,n)
  i=i+1;
  gbar_small_r(i)=semivar_synth(V,r)./V.par1;
end
i=0;
for r=linspace(0,scale_large,n)
  i=i+1;
  gbar_large_r(i)=semivar_synth(V,r)./V.par1;
end
gbar_small=mean(gbar_small_r);
gbar_large=mean(gbar_large_r);

%gbar = gammabar(scale_large,V)

%gbar_small=semivar_synth(V,scale_small)./V.par1;
%gbar_large=semivar_synth(Vb,scale_large)./V.par1;
gbar_small=gammabar(scale_small,V);
gbar_large=gammabar(scale_large,V);


disp(sprintf('Gamma Bar Small = %5.3f',gbar_small));
disp(sprintf('Gamma Bar Large = %5.3f',gbar_large));

%gbar_small=.0192;
%gbar_large=.436;

sill_large=V.par1*( (1-gbar_large)/(1-gbar_small) );
Vb.par1=sill_large;

% set random seed 
G.set.seed=13;
G.set.seed=12;

% Generate refernce data set
[sim]=gstat(G);

% block data
[bsim,bz]=block_log(sim,z,scale_large);

% plot refernce data
figure(1);

subplot(1,2,1)
plot(sim,z,'-',bsim,bz,'-o');
xlabel('Porosity %')
ylabel('Depth m')
set(gca,'ydir','reverse');
set(gca,'xlim',[15 35])
clear l;
l{1}=sprintf('Sim fine scale %3.2f m',scale_small);
l{2}=sprintf('Block average %3.2f m ',scale_large);
legend(l,'Location','SouthOutside')

subplot(2,2,2)
hx=linspace(10,40,20);
hsim=hist(sim,hx);
hbsim=hist(bsim,hx);
plot(hx,[hsim./length(sim);hbsim./length(bsim)])
legend(l,'Location','SouthOutside')

[g_sim,d_sim]=semivar_exp_gstat(z,sim,0,180,0.2,4);
[g_bsim,d_bsim]=semivar_exp_gstat(bz,bsim,0,180,0.2,8);
%[g_bsim,d_bsim]=semivar_exp_gstat(bz,bsim);
h_synth=linspace(0,4,80);
[g_sim_synth]=semivar_synth(V,h_synth);
[g_bsim_synth]=semivar_synth(Vb,h_synth);

subplot(2,2,4);
plot(d_sim,g_sim,'o-',d_bsim,g_bsim,'o-')
hold on
plot(h_synth,g_sim_synth,'k-','linewidth',1);
plot(h_synth,g_bsim_synth,'k-','linewidth',2);
hold off
xlabel('Distance m')  
ylabel('\gamma')  
grid on

l{3}=format_variogram(V);
l{4}=format_variogram(Vb);
legend(l,'Location','SouthOutside')
