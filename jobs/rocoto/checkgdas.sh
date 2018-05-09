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
configs="base"
for config in $configs; do
    . $EXPDIR/config.${config}
    status=$?
    [[ $status -ne 0 ]] && exit $status
done


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

mkdir -p $fv3ic_dir
cd $fv3ic_dir



# /5year/NCEPDEV/emc-global/emc.glopara/WCOSS_C/Q1FY19/prfv3rt1/gdas.2018041100/gdas.tar 
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
#hsi -q list $gdasfile
hsi ls -l $gdasfile
status=$?
if [[ $status -ne 0 ]]; then
  echo "missing $gdasfile on mass store..."
  exit 1
else
touch gdas_available

fi
