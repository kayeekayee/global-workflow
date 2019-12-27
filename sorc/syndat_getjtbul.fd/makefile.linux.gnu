SHELL=		/bin/sh
#LIBS=		-L/nwprod/lib -lw3nco_v2.0.5_4
#LIBS=		-L/contrib/nceplibs/nwprod/lib -lw3nco_v2.0.5_4
LIBS_SYN_GET = ${W3NCO_LIBd}
FC=		gfortran
#DEBUG = 	-ftrapuv  -check all  -fp-stack-check  -fstack-protector
##DEBUG = 	-ftrapuv  -fp-stack-check  -fstack-protector
#FFLAGS=		-O3 -g -traceback -assume noold_ldout_format $(DEBUG)
FFLAGS=     -O2 -g $(DEBUG)
LDFLAGS=	
SRCS=		getjtbul.f
OBJS=		getjtbul.o
CMD=		syndat_getjtbul

all:		$(CMD)

$(CMD):		$(OBJS)
	$(FC) $(LDFLAGS) -o $(@) $(OBJS) $(LIBS_SYN_GET)

clean:	
		-rm -f $(OBJS)

install:	
		-mv $(CMD) ../../exec/$(CMD)

