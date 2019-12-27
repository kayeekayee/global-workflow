SHELL=/bin/sh
#
SRCS= gdas_trpsfcmv.f getgb1.f 

OBJS= gdas_trpsfcmv.o getgb1.o 

FC =    gfortran 
LDFLAGS =  -L$(NCARG_LIB) \
           -lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lcairo -lfontconfig -lpixman-1 \
	   -lfreetype -lexpat -lpthread -lXrender -lgfortran
#	            -lfreetype -lexpat -lpng -lz -lpthread -lbz2 -lXrender -lgfortran

LIBS     = $(IP_LIBd) \
	$(SP_LIBd) \
	$(BACIO_LIB4) \
	$(W3NCO_LIBd) \
	$(BUFR_LIB8)

CMD =     gdas_trpsfcmv 
PROFLIB =       -lprof

FFLAGS = -O -g -fopenmp -fconvert=big-endian -fno-range-check

# Lines from here on down should not need to be changed.  They are the
# actual rules which make uses to build a.out.
#
all:            $(CMD)
	
$(CMD):         $(OBJS)
	$(FC) -o $(@) $(OBJS) $(LIBS) $(LDFLAGS) $(FFLAGS)

clean:
	-rm -f $(OBJS)
