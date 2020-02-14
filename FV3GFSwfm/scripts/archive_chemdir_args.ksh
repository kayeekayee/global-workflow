#!/bin/ksh -l

# this file archives chem output files to the mass store, /BMC/fim/1year/exp_chem/<experiment>
#    *nemsio, RESTART, *pgrb2*

# check for correct number of parameters
if [ $# -lt 4 ]; then
  echo "Usage:  $0 srcPath experiment yyyymmdd hh"
  exit 1
fi

module load hpss
module list

# initialize
srcDir=$1
experiment=$2
yyyymmdd=$3
hh=$4
mssDir=exp_chem/${experiment}/${yyyymmdd}${hh}
echo "****************************"
echo mssDIR:   $mssDir
echo DATE:     $yyyymmdd $hh

# for each directory, archive nemsio files, RESTART directory, and grib2 files to mass store in daily files
#    /scratch4/BMC/rtfim/rtruns/FV3-Chem/FV3GFSrun/rt_fv3gfs_chem/gfs.20180501/00
echo "Archiving ${yyyymmdd}${hh} to mss"
cd $srcDir/gfs.${yyyymmdd}/${hh}

## nemsio files
cmd="htar -cPvf /BMC/fim/1year/${mssDir}/${yyyymmdd}${hh}_nemsio.tar *nemsio*"
$cmd
status=$?
if [ $status -ne 0 ] ; then
  printf "Error : [%d] when executing htar command: '$cmd'" $status
#  #exit $status
fi

## RESTART directory
cmd="htar -cPvf /BMC/fim/1year/${mssDir}/${yyyymmdd}${hh}_restart.tar RESTART"
$cmd
status=$?
if [ $status -ne 0 ] ; then
  printf "Error : [%d] when executing htar command: '$cmd'" $status
#  #exit $status
fi

## GRIB2 files
cmd="htar -cPvf /BMC/fim/1year/${mssDir}/${yyyymmdd}${hh}_pgrb2.tar *pgrb2*"
$cmd
status=$?
if [ $status -ne 0 ] ; then
  printf "Error : [%d] when executing htar command: '$cmd'" $status
#  #exit $status
fi

