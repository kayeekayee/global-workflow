#!/bin/bash 

## this script makes links to GFS nemsio files under /public and copies over GFS analysis file for verification
##   /scratch4/BMC/rtfim/rtfuns/FV3GFS/FV3ICS/YYYYMMDDHH/gfs
##     sfcanl.gfs.YYYYMMDDHH -> /scratch4/BMC/public/data/grids/gfs/nemsio/YYDDDHH00.gfs.tHHz.sfcanl.nemsio
##     siganl.gfs.YYYYMMDDHH -> /scratch4/BMC/public/data/grids/gfs/nemsio/YYDDDHH00.gfs.tHHz.atmanl.nemsio

###############################################################
## Abstract:
## Get GFS intitial conditions
## RUN_ENVIR : runtime environment (emc | nco)
## HOMEgfs   : /full/path/to/workflow
## EXPDIR : /full/path/to/config/files
## CDATE  : current date (YYYYMMDDHH)
## CDUMP  : cycle name (gdas / gfs)
## PDY    : current date (YYYYMMDD)
## cyc    : current cycle (HH)
###############################################################

###############################################################
# Source FV3GFS workflow modules
. $HOMEgfs/ush/load_fv3gfs_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

###############################################################
# Source relevant configs
configs="base getic"
for config in $configs; do
    . $EXPDIR/config.${config}
    status=$?
    [[ $status -ne 0 ]] && exit $status
done

###############################################################
# Source machine runtime environment
. $BASE_ENV/${machine}.env getic
status=$?
[[ $status -ne 0 ]] && exit $status

###############################################################
# Set script and dependency variablesyyyymmdd=`echo $CDATE | cut -c1-8`
yyyymmdd=$(echo $CDATE | cut -c1-8)
hh=$(echo $CDATE | cut -c9-10)
yyyy=$(echo $CDATE | cut -c1-4)
mm=$(echo $CDATE | cut -c5-6)
dd=$(echo $CDATE | cut -c7-8)
yyddd=$(date +%y%j -u -d $yyyymmdd)


echo
echo "CDATE = $CDATE"
echo "CDUMP = $CDUMP"
echo "ICSDIR = $ICSDIR"
echo "PUBDIR = $PUBDIR"
echo "GDASDIR = $GDASDIR"
echo "ROTDIR = $ROTDIR"
echo "PSLOT = $PSLOT"
echo

## initialize
fv3ic_dir=$ICSDIR/$CDATE/$CDUMP

## create links in FV3ICS directory
mkdir -p $fv3ic_dir
cd $fv3ic_dir
echo "making link to nemsio files under $fv3ic_dir"

ln -fs $PUBDIR/${yyddd}${hh}00.${CDUMP}.t${hh}z.sfcanl.nemsio sfcanl.gfs.${CDATE}
ln -fs $PUBDIR/${yyddd}${hh}00.${CDUMP}.t${hh}z.atmanl.nemsio siganl.gfs.${CDATE}



# /5year/NCEPDEV/emc-global/emc.glopara/WCOSS_C/Q1FY19/prfv3rt1/201804110/gdas.tar 
#      ./gdas.20180411/00/gdas.t00z.atmanl.nemsio
#      ./gdas.20180411/00/gdas.t00z.sfcanl.nemsio
#

# check for correct number of parameters

#if [ $# -lt 2 ]; then
#  echo "   Usage:  $0  YYYYMMDD HH"
#  exit 1
#fi

#yyyymmdd=$1
#hh=$2

echo "YYYYMMDDHH:  ${yyyymmdd}${hh}"

gdasfile=$GDASDIR/${yyyymmdd}${hh}/gdas.tar
hsi -q list $gdasfile
status=$?
if [[ $status -ne 0 ]]; then
  echo "missing $gdasfile on mass store..."
  exit 1
fi
htar -xvf ${gdasfile} ./gdas.${yyyymmdd}/${hh}/gdas.t${hh}z.atmanl.nemsio

        rc=$?
        if [ $rc -ne 0 ]; then
            echo "untarring $tarball failed, ABORT!"
            exit $rc
        fi
mv ./gdas.${yyyymmdd}/${hh}/gdas.t${hh}z.atmanl.nemsio .
rm -rf ./gdas.${yyyymmdd}
echo $hpss_dir
echo $gdasfile


 


