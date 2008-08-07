B0=[25 0;0 9];
B1=[20 18;18 29];

g0str='1 Nug(0) + 1 Sph(4)'
g0=deformat_variogram(g0str);

g11=g0;
g11(1).par1=B0(1,1);
g11(2).par1=B1(1,1);
g22=g0;
g22(1).par1=B0(2,2);
g22(2).par1=B1(2,2);
g12=g0;
g12(1).par1=B0(1,2);
g12(2).par1=B1(1,2);


x=[0:.1:10];
[sv11]=semivar_synth(g11,x);
[sv12]=semivar_synth(g12,x);
[sv22]=semivar_synth(g22,x);
subplot(2,3,1)
plot(x,sv11)
axis([0 max(x) 0 50])
title('\gamma_{11}(h)')
text(.1,.1,['b_{11}^0=',num2str(B0(1,1))],'units','normalized')
text(.1,.2,['b_{11}^1=',num2str(B1(1,1))],'units','normalized')

subplot(2,3,2)
plot(x,sv22)
axis([0 max(x) 0 50])
title('\gamma_{22}(h)')
text(.1,.1,['b_{22}^0=',num2str(B0(2,2))],'units','normalized')
text(.1,.2,['b_{22}^1=',num2str(B1(2,2))],'units','normalized')

subplot(2,3,3)
plot(x,sv12)
axis([0 max(x) 0 50])
title('\gamma_{12}(h)')
text(.1,.1,['b_{12}^0=',num2str(B0(1,2))],'units','normalized')
text(.1,.2,['b_{12}^1=',num2str(B1(1,2))],'units','normalized')

suptitle(['Linear Model Of Coregionalization\newlineg_0 = ',g0str])
print -dpng GoovaertsChap4_f4_15top.png

%
% INTRINSIC
%
PHI=[12 10; 10 15];
g11=g0;
g11(1).par1=g11(1).par1.*PHI(1,1)
g11(2).par1=g11(2).par1.*PHI(1,1)
g22=g0;
g22(1).par1=g22(1).par1.*PHI(2,2)
g22(2).par1=g22(2).par1.*PHI(2,2)
g12=g0;
g12(1).par1=g12(1).par1.*PHI(1,2)
g12(2).par1=g12(2).par1.*PHI(1,2)

x=[0:.1:10];
[sv11]=semivar_synth(g11,x);
[sv12]=semivar_synth(g12,x);
[sv22]=semivar_synth(g22,x);


figure
subplot(2,3,1)
plot(x,sv11)
axis([0 max(x) 0 50])
title('\gamma_{11}(h)')
text(.1,.1,['\phi_{11}^0=',num2str(PHI(1,1))],'units','normalized')


subplot(2,3,2)
plot(x,sv22)
axis([0 max(x) 0 50])
title('\gamma_{22}(h)')
text(.1,.1,['\phi_{22}^0=',num2str(PHI(2,2))],'units','normalized')


subplot(2,3,3)
plot(x,sv12)
axis([0 max(x) 0 50])
title('\gamma_{12}(h)')
text(.1,.1,['\phi_{12}^0=',num2str(PHI(1,2))],'units','normalized')

suptitle(['Intrinsic Model Of Coregionalization\newlineg_0 = ',g0str])
print -dpng GoovaertsChap4_f4_15base.png

