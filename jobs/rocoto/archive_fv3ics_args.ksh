#!/bin/ksh -l

# this file archives FV3 ICs to the mass store, /BMC/fim/5year/FV3ICS
#    input is operational GFS initial conditions

module load hpss
module list

# check for correct number of parameters
if [ $# -lt 4 ]; then
  echo "Usage:  $0 yyyymmddhh mssDir [FV3ICS | FV3ICS_L127]  CASE [C384 C768] /home/role.rtfim/UFS-CAMsuite/FV3GFSrun/FV3ICS_L127"
  exit 1
fi

# initialize
CDUMP=gfs
yyyymmddhh=$1
yyyy=${yyyymmddhh:0:4}
mm=${yyyymmddhh:4:2}
ICDir=$2
mssDir=${ICDir}/${yyyy}/${mm}
CASE=$3
ICSDIR=$4
#ICSDIR=/scratch4/BMC/rtfim/rtruns/FV3ICS/${yyyymmddhh}
echo "****************************"
echo ICSDIR:   $ICSDIR
echo mssDIR:   $mssDir
echo CDUMP:    $CDUMP
echo CASE:     $CASE
echo DATE:     $yyyymmddhh

# for each directory, archive FV3 ICs to mass store in monthly directories
#    /scratch4/BMC/rtfim/rtruns/FV3GFS/FV3ICS/2017111012/gfs/C384/INPUT
echo "in $ICSDIR....."
echo "Archiving ${yyyymmddhh} to mss"
cd $ICSDIR
cmd="htar -cPvf /BMC/fim/5year/${mssDir}/${yyyymmddhh}_${CASE}.tar ${CDUMP}/${CASE}/INPUT/*"
$cmd
status=$?
if [ $status != 0 ] ; then
  printf "Error : [%d] when executing htar command: '$cmd'" $status
  exit $status
fi
