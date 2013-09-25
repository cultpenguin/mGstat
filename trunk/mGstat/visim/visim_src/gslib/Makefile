#
# Makefile for generating "libgs.a"
#

COMP = gfortran
#FFLAGS = -c -m32 -O
FFLAGS = -c -O3 -static

LIBGS = ../libgs.a
SRCS = acorni.f acorni2.f backtr.f beyond.f blue.f chknam.f chktitle.f cova3.f \
	dlocate.f dpowint.f dsortem.f gauinv.f gcum.f getindx.f \
	green.f hexa.f ksol.f ktsol.f locate.f nscore.f numtext.f \
	ordrel.f picksupr.f powint.f nearint.f psfill.f psline.f pstext.f rand.f \
	red.f resc.f scal.f setrot.f setsupr.f sortem.f sqdist.f \
	srchsupr.f strlen.f 
OBJS = $(SRCS:.f=.o)


all: $(LIBGS)

$(LIBGS): $(OBJS)
	ar q $@ $(OBJS)
	ar ts $@

.f.o:

	$(COMP) $(FFLAGS) $*.f

clean:
	/bin/rm -rf $(OBJS) $(LIBGS) core
