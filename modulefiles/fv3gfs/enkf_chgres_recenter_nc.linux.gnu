#!/bin/bash

#%Module######################################################################
##

echo "Setting environment variables for enkf_chgres_recenter on Linux with gcc/gfortran"

export FC=gfortran
export FFLAGS="-O3 -fdefault-real-8 -fopenmp"
