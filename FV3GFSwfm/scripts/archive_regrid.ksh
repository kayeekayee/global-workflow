#!/bin/ksh -l

# this file archives realtime directory files to the mass store, /BMC/fim/1year/rtFV3-Chem/

# check for correct number of parameters
if [ $# -lt 2 ]; then
  echo "Usage:  $0 yyyymmdd hh"
  exit 1
fi

module load hpss
module list

# initialize
yyyymmdd=$1
hh=$2
srcDir=/home/rtfim/FV3-Chem/FV3GFSrun/rt_fv3gfs_chem/
mssDir=rt_FV3-Chem/${yyyymmdd}${hh}
runDir=/scratch1/BMC/gsd-fv3/NCEPDEV/stmp3/rtfim/RUNDIRS/rt_fv3gfs_chem
echo "****************************"
echo mssDIR:   $mssDir
echo DATE:     $yyyymmdd $hh

# for each directory, archive nemsio files, RESTART directory, and grib2 files to mass store in daily files
#    /home/rtfim/FV3-Chem/FV3GFSrun/rt_fv3gfs_chem/gfs.20180501/00
echo "Archiving ${yyyymmdd}${hh} to mss"
cd $runDir/${yyyymmdd}${hh}/gfs

## regrid directory
cmd="htar -cPvf /BMC/fim/1year/${mssDir}/${yyyymmdd}${hh}_regrid.tar regrid"
$cmd
status=$?
if [ $status -ne 0 ] ; then
  printf "Error : [%d] when executing htar command: '$cmd'" $status
  #exit $status
fi
