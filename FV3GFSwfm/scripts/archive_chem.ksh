#!/bin/ksh -l

# this file archives realtime directory files to the mass store, /BMC/fim/1year/rtFV3-Chem/

module load hpss
module list

# initialize
#yyyymmdd=$1
#hh=$2
#srcDir=/home/rtfim/FV3-Chem/FV3GFSrun/rt_fv3gfs_chem/
mssDir=/BMC/fim/1year/rt_FV3-Chem/${yyyymmdd}${hh}
echo "****************************"
echo srcDir:   $srcDir
echo mssDIR:   $mssDir
echo DATE:     $yyyymmdd $hh

# for each directory, archive nemsio files, RESTART directory, and grib2 files to mass store in daily files
#    /home/rtfim/FV3-Chem/FV3GFSrun/rt_fv3gfs_chem/gfs.20180501/00
echo "Archiving ${yyyymmdd}${hh} to mss"
cd $srcDir/gfs.${yyyymmdd}/${hh}

## nemsio files
cmd="htar -cPvf ${mssDir}/${yyyymmdd}${hh}_nemsio.tar *nemsio*"
$cmd
status=$?
if [ $status -ne 0 ] ; then
  printf "Error : [%d] when executing htar command: '$cmd'" $status
  #exit $status
fi

## RESTART directory
cmd="htar -cPvf ${mssDir}/${yyyymmdd}${hh}_restart.tar RESTART"
$cmd
status=$?
if [ $status -ne 0 ] ; then
  printf "Error : [%d] when executing htar command: '$cmd'" $status
  #exit $status
fi

## GRIB2 files
cmd="htar -cPvf ${mssDir}/${yyyymmdd}${hh}_pgrb2.tar *pgrb2*"
$cmd
status=$?
if [ $status -ne 0 ] ; then
  printf "Error : [%d] when executing htar command: '$cmd'" $status
  #exit $status
fi

## NCL files
cmd="htar -cPvf ${mssDir}/${yyyymmdd}${hh}_ncl.tar ncl/*/files.zip"
$cmd
status=$?
if [ $status -ne 0 ] ; then
  printf "Error : [%d] when executing htar command: '$cmd'" $status
  #exit $status
fi
