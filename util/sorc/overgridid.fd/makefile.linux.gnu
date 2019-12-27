LIBS =    ${W3NCO_LIBd} ${BACIO_LIB4}
OBJS=     overgridid.o
overgridid:	overgridid.f
	gfortran -o overgridid overgridid.f $(LIBS)
clean:
	-rm -f $(OBJS)


