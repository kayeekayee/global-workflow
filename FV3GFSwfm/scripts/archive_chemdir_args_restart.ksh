#!/bin/ksh -l

# this file archives chem RESTART files to the mass store, /BMC/fim/1year/exp_chem/<experiment>
#    RESTART

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

# for each directory, archive RESTART directory to mass store in daily files
#    /scratch4/BMC/rtfim/rtruns/FV3-Chem/FV3GFSrun/rt_fv3gfs_chem/gfs.20180501/00
echo "Archiving ${yyyymmdd}${hh} to mss"
echo "cd $srcDir/gfs.${yyyymmdd}/${hh}"
cd $srcDir/gfs.${yyyymmdd}/${hh}

## RESTART directory
if [[ -d RESTART ]]; then
  cmd="htar -cPvf /BMC/fim/1year/${mssDir}/${yyyymmdd}${hh}_restart.tar RESTART/\*0000\.\*"
  $cmd
  status=$?
  if [ $status -ne 0 ] ; then
    printf "Error : [%d] when executing htar command: '$cmd'" $status
  #  #exit $status
  fi
else
  echo "No RESTART directory to archive!"
fi

