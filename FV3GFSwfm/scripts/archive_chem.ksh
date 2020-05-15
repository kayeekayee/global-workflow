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
if [[ -f gfs.t${hh}z.atmf000.nemsio ]]; then 
  cmd="htar -cPvf ${mssDir}/${yyyymmdd}${hh}_nemsio.tar *nemsio*"
  $cmd
  status=$?
  if [ $status -ne 0 ] ; then
    printf "Error : [%d] when executing htar command: '$cmd'" $status
    #exit $status
  fi
else
  echo "No nemsio files to archive!"
fi

## RESTART directory
if [[ -d RESTART ]]; then
  cmd="htar -cPvf ${mssDir}/${yyyymmdd}${hh}_restart.tar RESTART/\*0000\.\*"
  $cmd
  status=$?
  if [ $status -ne 0 ] ; then
    printf "Error : [%d] when executing htar command: '$cmd'" $status
    #exit $status
  fi
else
  echo "No RESTART directory to archive!"
fi
  
## GRIB2 files
if [[ -f *pgrb2* ]]; then 
  cmd="htar -cPvf ${mssDir}/${yyyymmdd}${hh}_pgrb2.tar *pgrb2*"
  $cmd
  status=$?
  if [ $status -ne 0 ] ; then
    printf "Error : [%d] when executing htar command: '$cmd'" $status
    #exit $status
  fi
else
  echo "No grib2 files to archive!"
fi

## NCL files
if [[ -f ncl/*/files.zip ]]; then 
  cmd="htar -cPvf ${mssDir}/${yyyymmdd}${hh}_ncl.tar ncl/*/files.zip"
  $cmd
  status=$?
  if [ $status -ne 0 ] ; then
    printf "Error : [%d] when executing htar command: '$cmd'" $status
    #exit $status
  fi
else
  echo "No ncl zip files to archive!"
fi
