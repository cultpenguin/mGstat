% Goovaerts Example : Chapter 4


% Matlab Example File for Goovaerts Chapter 4
%

% load data
[p,pHeader]=read_eas('prediction.dat');



% Figure 4.6 Bounded semivariogram
h=[0:.01:2];

[sv_gau]=semivar_synth('1.0 Gau(1)',h);
[sv_sph]=semivar_synth('1.0 Sph(1)',h);
[sv_exp]=semivar_synth('1.0 Exp(1)',h);
[sv_nug]=semivar_synth('1.0 Nug(1)',h);
[sv_log]=semivar_synth('1.0 Log(1)',h);
[sv_pow1]=semivar_synth('1.0 Pow(.5)',h);
[sv_pow2]=semivar_synth('1.0 Pow(1)',h);
[sv_pow3]=semivar_synth('1.0 Pow(1.5)',h);
[sv_lin]=semivar_synth('1.0 Lin(1)',h);
figure
plot(h,sv_sph,'k-','linewidth',2)
hold on
plot(h,sv_exp,'k--','linewidth',2)
plot(h,sv_gau,'k-.','linewidth',2)
plot(h,sv_nug,'k-','linewidth',1)

plot([1 1],[0 1.1],'b-')
text(1.05,.4,'Range=1')
text(.05,1.03,'Sill=1')
ylabel('Semivariogram ,\gamma')
xlabel(['distance'])
hold off
title('Transitional Semivariogram models for, range=1, sill=1')
axis([min(h) max(h) 0 1.1])
legend('Sph','Exp','Gau','Nug')
% print -dpng GoovChap4_fig4.6a.png


figure
plot(h,sv_lin,'k-.','linewidth',2)
hold on
plot(h,sv_log,'k--','linewidth',2)
plot(h,sv_pow1,'k-','linewidth',1)
plot(h,sv_pow2,'k-','linewidth',2)
plot(h,sv_pow3,'k-','linewidth',3)
hold off
legend('Lin','Log','Pow(0.5)','Pow(1)','Pow(1.5)',4)
axis([0 max(h) 0 max(h)])
print -dpng GoovChap4_fig4.6b.png

%
figure;
iicon=6;
[hc,garr]=semivar_exp([p(:,1) p(:,2)],p(:,iicon));
plot(hc,garr,'*');

V='14 Sph(1.0)';
[sv]=semivar_synth(V,hc);
hold on
plot(hc,sv,'k-')
hold off
legend(['Exp. ',pHeader{iicon}],V,4)
ylabel('Semivariogram ,\gamma')
xlabel(['distance'])
ax=axis;axis([0 ax(2) 0 ax(4)])
print -dpng GoovChap4_isomatch.png


% LMR 

V1='0.3 Nug(0)';
V2='0.3 Sph(.2)';
V3='0.26 Sph(1.3)';
V_lvm='0.3 Nug(0) + 0.3 Sph(.2) + 0.26 Sph(1.3)';

h=[0:.01:4];
[sv1]=semivar_synth(V1,h);
[sv2]=semivar_synth(V2,h);
[sv3]=semivar_synth(V3,h);
[sv_lvm]=semivar_synth(V_lvm,h);
plot(h,sv1,'k-',h,sv2,'r-',h,sv3,'g-',h,sv_lvm,'b-')
ylabel('Semivariogram ,\gamma')
xlabel(['distance'])
title('Linear Model of Regionalization')
legend(V1,V2,V3,V_lvm,4)
print -dpng GoovChap4LVM.png
