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
cd $srcDir/gfs.${yyyymmdd}/${hh}

## nemsio files
cmd="htar -cPvf /BMC/fim/1year/${mssDir}/${yyyymmdd}${hh}_nemsio.tar *nemsio*"
$cmd
status=$?
if [ $status -ne 0 ] ; then
  printf "Error : [%d] when executing htar command: '$cmd'" $status
  #exit $status
fi

## RESTART directory
cmd="htar -cPvf /BMC/fim/1year/${mssDir}/${yyyymmdd}${hh}_restart.tar RESTART/\*0000\.\*"
$cmd
status=$?
if [ $status -ne 0 ] ; then
  printf "Error : [%d] when executing htar command: '$cmd'" $status
  #exit $status
fi

## GRIB2 files
cmd="htar -cPvf /BMC/fim/1year/${mssDir}/${yyyymmdd}${hh}_pgrb2.tar *pgrb2*"
$cmd
status=$?
if [ $status -ne 0 ] ; then
  printf "Error : [%d] when executing htar command: '$cmd'" $status
  #exit $status
fi

## NCL files
cmd="htar -cPvf /BMC/fim/1year/${mssDir}/${yyyymmdd}${hh}_ncl.tar ncl/*/files.zip"
$cmd
status=$?
if [ $status -ne 0 ] ; then
  printf "Error : [%d] when executing htar command: '$cmd'" $status
  #exit $status
fi

## regrid directory
cd $runDir/${yyyymmddhh}/gfs
cmd="htar -cPvf /BMC/fim/1year/${mssDir}/${yyyymmdd}${hh}_regrid.tar regrid"
$cmd
status=$?
if [ $status -ne 0 ] ; then
  printf "Error : [%d] when executing htar command: '$cmd'" $status
  #exit $status
fi
