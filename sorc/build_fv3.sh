#! /usr/bin/env bash
set -eux

source ./machine-setup.sh > /dev/null 2>&1
cwd=`pwd`

USE_PREINST_LIBS=${USE_PREINST_LIBS:-"true"}
if [ $USE_PREINST_LIBS = true ]; then
  export MOD_PATH=/lfs4/HFIP/hfv3gfs/nwprod/NCEPLIBS/modulefiles
else
  export MOD_PATH=${cwd}/lib/modulefiles
fi

# Check final exec folder exists
if [ ! -d "../exec" ]; then
  mkdir ../exec
fi

if [ $target = hera ]; then target=hera.intel ; fi
if [ $target = jet ]; then target=jet.intel ; fi
if [ $target = orion ]; then target=orion.intel ; fi

cd fv3gfs.fd/
FV3=$( pwd -P )/FV3
cd tests/

if [ ${RUN_CCPP:-${1:-"NO"}} = "NO" ]; then
 ./compile.sh "$FV3" "$target" "WW3=Y 32BIT=Y" 1
 mv -f fv3_1.exe ../NEMS/exe/global_fv3gfs.x
else
 ./compile.sh "$target" "32BIT=Y SUITES=FV3_GFS_v15,FV3_GFS_v16,FV3_GSD_noah,FV3_GSD_v0" 2 NO NO
 mv -f fv3_2.exe ../NEMS/exe/global_fv3gfs.x
fi
