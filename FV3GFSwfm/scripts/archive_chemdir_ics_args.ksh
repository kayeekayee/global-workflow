#!/bin/ksh -l

# this file archives FV3-Chem ICs to the mass store, /BMC/fim/5year/FV3_ICs_GFS
#    input is operational GFS nemsio initial conditions
#             operational GFS netcdf initial conditions starting 03/12/21 12Z

# check for correct number of parameters
if [ $# -lt 4 ]; then
  echo "Usage:  $0 ICSDIR destPath yyyymmddhh CASE [C384 C96]"
  exit 1
fi

module load hpss
module list

# initialize
CDUMP=gfs
srcDir=$1
destPath=$2
yyyymmddhh=$3
CASE=$4

ICSDIR=${srcDir}/${yyyymmddhh}
yyyy=${yyyymmddhh:0:4}
mm=${yyyymmddhh:4:2}
mssDir=${destPath}/${yyyy}/${mm}

echo "****************************"
echo ICSDIR:   $ICSDIR
echo mssDIR:   $mssDir
echo CDUMP:    $CDUMP
echo CASE:     $CASE
echo DATE:     $yyyymmddhh

# make directory on mass store
echo "creating $mssDir....."
cmd="hsi mkdir $mssDir"
$cmd
status=$?
if [ $status != 0 ] ; then
  printf "Error : [%d] when executing hsi command: '$cmd'" $status
  exit $status
fi

# for each directory, archive FV3 ICs to mass store in monthly directories
#    ${destPath}/YYYYMMDDHH/gfs/${CASE}/INPUT
echo "in $ICSDIR....."
echo "Archiving ${CASE} ICS for ${yyyymmddhh} to mss"
cd $ICSDIR
cmd="htar -cPvf ${mssDir}/${yyyymmddhh}_${CASE}.tar ${CDUMP}/${CASE}/INPUT/*"
$cmd
status=$?
if [ $status != 0 ] ; then
  printf "Error : [%d] when executing htar command: '$cmd'" $status
  exit $status
fi
