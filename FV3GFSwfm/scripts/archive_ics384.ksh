#!/bin/ksh -l

# this file archives FV3-Chem ICs to the mass store, /BMC/fim/5year/FV3_ICs_GFS
#    input is operational GFS nemsio initial conditions
#             operational GFS netcdf initial conditions starting 03/12/21 12Z

module load hpss
module list

# initialize
#inpDir=/scratch1/BMC/gsd-fv3/rtruns/FV3-Chem/FV3ICS
#mssDir=FV3_ICs_GFS
#CDUMP=gfs
#CASE=C384
#yyyymmddhh=$1
echo "****************************"
echo ICSDIR:   $ICSDIR
echo mssDIR:   $mssDir
echo CDUMP:    $CDUMP
echo CASE:     $CASE
echo DATE:     $yyyymmddhh

# for each directory, archive FV3 ICs to mass store in monthly directories
#    /scratch1/BMC/gsd-fv3/rtruns/FV3-Chem/FV3ICS/YYYYMMDDHH/gfs/C384/INPUT
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
