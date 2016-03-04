#!/bin/sh
#
# DOWNLOADS AND COMPILES NFD
#

COMP=gfortran

# GET SOURCE FILE. 
echo "See http://www.geophysics.rice.edu/department/faculty/zelt/fast.html for info the FAST package"
echo "This scipt only compiles NFD, not the full FAST packed"
pause "continue"

wget http://terra.rice.edu/department/faculty/zelt/fast.tar.gz

tar xvfz fast.tar.gz
cd fast

# ADJUSTMENTS
sed -i 's/parameter(nxmax=601, nymax=1, nzmax=25, ncolour=10/parameter(nxmax=2001, nymax=1, nzmax=2001, ncolour=10/g' fd/fd.par
sed -i 's/      write(6,335)/c     write(6,335)/g' fd/main.f 
sed -i 's/335   format/c335   format/g' fd/main.f 

# COMPILE
find ./pltlib -name '*.f' -exec $COMP -c {} \;
find ./fd -name '*.f' -exec $COMP -c {} \;
$COMP -o nfd -static main.o model.o time.o findiff.o findiff2d.o stencils.o stencils2d.o misc.o plt.o blkdat.o nopltlib.o
cp nfd ../.