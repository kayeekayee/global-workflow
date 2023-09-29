#!/bin/sh 

## this script makes a link to CCPP-Chem regrid directory
##
##   ln -s $RUNDIR1/$CDATE/$CDUMP/regrid $RUNDIR/$CDATE/$CDUMP/regrid 
##
##   where RUNDIR1 is set to /scratch1/BMC/gsd-fv3/NCEPDEV/stmp3/role.rtfim/RUNDIRS/rt_ccpp-chem
##   where RUNDIR  is set to /scratch1/BMC/gsd-fv3/NCEPDEV/stmp3/role.rtfim/RUNDIRS/rt_fv3gfs-chem
##

echo
echo "CDATE = $CDATE"
echo "CDUMP = $CDUMP"
echo "RUNDIR = $RUNDIR"
echo "RUNDIR1 = $RUNDIR1"
echo

## create link to regrid directory for CCPP-Chem experiment
cd $RUNDIR/${CDATE}/${CDUMP}
if [[ ! -d regrid ]]; then 
  ln -sf $RUNDIR1/$CDATE/$CDUMP/regrid regrid
  status=$?
  if [ $status -ne 0 ]; then
    echo "can't make link to ${RUNDIR1}/${CDATE}/${CDUMP}...."
    return $status
  else
    echo "making link to CCPP-Chem regrid directory for ${CDATE}"
  fi
else
  echo "directory regrid already exists!"
fi
