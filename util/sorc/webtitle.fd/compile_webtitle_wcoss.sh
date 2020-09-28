#!/bin/sh

######################################################################
#
# Build executable : GFS utilities
#
######################################################################

LMOD_EXACT_MATCH=no
source ../../../sorc/machine-setup.sh > /dev/null 2>&1
cwd=`pwd`

if [ "$target" = "wcoss_dell_p3" ] || [ "$target" = "wcoss_cray" ] || [ "$target" = "hera" ] ; then
   echo " "
   echo " You are on WCOSS:  $target "
   echo " "
elif [ "$target" = "wcoss" ] ; then
   echo " "
   echo " "
   echo " You are on WCOSS:  $target "
   echo " You do not need to build GFS utilities for GFS V15.0.0 "
   echo " "
   echo " "
   exit
elif [ "$target" = "linux.gnu" ] || [ "$target" = "linux.intel" ] ; then
   echo " You are on a $target machine."
else
   echo " "
   echo " Your machine is $target is not recognized as a WCOSS machine."
   echo " The script $0 can not continue.  Aborting!"
   echo " "
   exit
fi
echo " "

# Load required modules
source ../../modulefiles/gfs_util.${target}
module list

set -x

mkdir -p ../../exec
if [ "$target" = "linux.gnu" ] ; then
make -f makefile.linux.gnu
elif [ "$target" = "linux.intel" ] ; then
make -f makefile.intel.intel
else
make
fi
mv webtitle ../../exec
make clean
