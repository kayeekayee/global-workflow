SHELL=  /bin/sh
ISIZE = 4
RSIZE = 8
COMP=   gfortran
##INC = /contrib/nceplibs/nwprod/lib/incmod/g2_d
INC=${G2_INCd}
##LIBS=   -L/contrib/nceplibs/nwprod/lib -lw3emc_d -lw3nco_d -lg2_d -lbacio_4 -ljasper -lpng -lz
LIBS= ${W3EMC_LIBd} ${W3NCO_LIBd} ${BACIO_LIB4} ${G2_LIBd} -ljasper -lpng -lz 
LDFLAGS=
# FFLAGS= -O3 -I $(INC)  -i$(ISIZE) -r$(RSIZE)
# DEBUG= -check all -debug all -traceback
FFLAGS= -O2 -g -fdefault-real-$(RSIZE) -I$(INC)


vint:      vint.f
	@echo " "
	@echo "  Compiling the interpolation program....."
	$(COMP) $(FFLAGS) $(LDFLAGS) vint.f $(LIBS) -o vint.x
	@echo " "

.PHONY: clean

CMD =   vint.x

clean:
	-rm -f  *.o  *.mod

install:
	mv $(CMD) ../../exec/$(CMD)

