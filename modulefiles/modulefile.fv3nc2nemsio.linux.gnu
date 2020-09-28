#!/bin/bash

#%Module######################################################################
##

echo "Setting environment variables for fv3nc2 on Linux with gcc/gfortran"

export FCMP="gfortran"
export FFLAGS="-g -O2"
