#!/bin/ksh -l

# this file archives nemsio files to the mass store, /BMC/fim/1year/FV3-Chem

# check for correct number of parameters
if [ $# -lt 2 ]; then
  echo "Usage:  $0 yyyymmdd hh"
  exit 1
fi

module load hpss
module list

# initialize
srcDir=/scratch4/BMC/rtfim/rtruns/FV3-Chem/FV3GFSrun/rt_fv3gfs_chem
mssDir=FV3-Chem
yyyymmdd=$1
hh=$2
echo "****************************"
echo mssDIR:   $mssDir
echo DATE:     $yyyymmdd $hh

# for each directory, archive nemsio files to mass store in daily files
#    /scratch4/BMC/rtfim/rtruns/FV3-Chem/FV3GFSrun/rt_fv3gfs_chem/gfs.20180501/00
echo "Archiving ${yyyymmdd}${hh} to mss"
cd $srcDir/gfs.${yyyymmdd}/${hh}
cmd="htar -cPvf /BMC/fim/1year/${mssDir}/${yyyymmdd}${hh}.tar *nemsio*"
$cmd
status=$?
if [ $status != 0 ] ; then
  printf "Error : [%d] when executing htar command: '$cmd'" $status
  exit $status
fi
