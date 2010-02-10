#-----------------------------------------------------------------------
#
#                     Generic GSLIB Makefile
#                     **********************
#
progname=visim
#
#
#-----------------------------------------------------------------------
PROG   = $(progname)
PROG = visim

COMP = ifort
#FFLAGS = -fdefault-real-8 -fdefault-double-8 -O
FFLAGS = -O

#COMP = g77
#COMP = gfortran
#FFLAGS = -march=i386 -O2 
## FFLAGS = -g

SRCS   =  $(progname).f visim_krige.f visim_krige_volume.f \
                        visim_randpath.f visim_nhoodvol.f \
	                visim_makepar.f visim_readpar.f \
                        visim_setup_krgvar.f visim_ctable.f \
			visim_srchnd.f visim_trans.f \
			visim_getz.f visim_simu.f\
			visim_visim.f visim_condtab.f\
			visim_cov_vol2vol.f visim_cov_data2vol.f

LIBGS = libgs.a

SRCS_LIBGS = gslib/acorni.f gslib/backtr.f gslib/beyond.f gslib/blue.f gslib/chknam.f gslib/chktitle.f gslib/cova3.f \
	gslib/dlocate.f gslib/dpowint.f gslib/dsortem.f gslib/gauinv.f gslib/gcum.f gslib/getindx.f \
	gslib/green.f gslib/hexa.f gslib/ksol.f gslib/ktsol.f gslib/locate.f gslib/nscore.f gslib/numtext.f \
	gslib/ordrel.f gslib/picksupr.f gslib/powint.f gslib/psfill.f gslib/psline.f gslib/pstext.f gslib/rand.f \
	gslib/red.f gslib/resc.f gslib/scal.f gslib/setrot.f gslib/setsupr.f gslib/sortem.f gslib/sqdist.f \
	gslib/srchsupr.f gslib/strlen.f



OBJS_LIBGS = $(SRCS_LIBGS:.f=.o)

OBJS = $(SRCS:.f=.o)
INCS   =  $(progname).inc
LIBS   = libgs.a

all:$(PROG) 
$(PROG):$(OBJS)
	$(COMP) -o $@ $(OBJS) $(LIBS)

.f.o:
	$(COMP) -c $(FFLAGS) $<
$(OBJS):$(INCS)


$(LIBGS): $(OBJS_LIBGS)
	ar q $@ $(OBJS_LIBGS)
	ar ts $@


clean:
	/bin/rm -rf $(OBJS) $(PROG)
	/bin/rm -rf $(OBJS_LIBGS) $(LIBS)
