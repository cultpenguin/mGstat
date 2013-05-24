FC=gfortran
LIB=gslib/gslib.a

PROG = snesim

all: snesim

snesim: gslib
	$(FC) $(PROG).f gslib/gslib.a -o $(PROG)

gslib:
	cd gslib; make; cd ..

clean:
	cd gslib; make clean; cd ..; rm $(PROG)
