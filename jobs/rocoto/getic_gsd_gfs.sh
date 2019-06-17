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
# Set script and dependency variables
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
echo "GFSDIR = $GFSDIR"
echo "ARCDIR = $ARCDIR"
echo "GDASDIR = $GDASDIR"
echo "GDASDIR1 = $GDASDIR1" ##for retro run path
echo "ROTDIR = $ROTDIR"
echo "PSLOT = $PSLOT"
echo

## initialize
fv3ic_dir=$ICSDIR/$CDATE/$CDUMP

## create links in FV3ICS directory
mkdir -p $fv3ic_dir
cd $fv3ic_dir
echo "making link to nemsio files under $fv3ic_dir"

if [[ -f $PUBDIR/${yyddd}${hh}00.${CDUMP}.t${hh}z.sfcanl.nemsio ]]
then

  ln -fs $PUBDIR/${yyddd}${hh}00.${CDUMP}.t${hh}z.sfcanl.nemsio sfcanl.gfs.${CDATE}
  ln -fs $PUBDIR/${yyddd}${hh}00.${CDUMP}.t${hh}z.atmanl.nemsio siganl.gfs.${CDATE}
else

  echo "YYYYMMDDHH:  ${yyyymmdd}${hh}"
  
  gfsfile=$GFSDIR/${yyyy}/${mm}/${dd}/data/grids/gfs/nemsio/${yyyymmdd}${hh}00.zip
  hsi -q list $gfsfile
  status=$?
  if [[ $status -ne 0 ]]; then
    echo "missing $gfsfile on mass store..."
    exit 1
  fi
  hsi get $gfsfile
  unzip -o ${yyyymmdd}${hh}00.zip ${yyddd}${hh}00.gfs.t${hh}z.atmanl.nemsio
  unzip -o ${yyyymmdd}${hh}00.zip ${yyddd}${hh}00.gfs.t${hh}z.sfcanl.nemsio
  
  rc=$?
  if [ $rc -ne 0 ]; then
      echo "unzipping failed, ABORT!"
      exit $rc
  fi
  rm -rf ${yyyymmdd}${hh}00.zip
  
  
  if [[ -f ${yyddd}${hh}00.gfs.t${hh}z.sfcanl.nemsio ]]
  then
    ln -fs ${yyddd}${hh}00.gfs.t${hh}z.sfcanl.nemsio sfcanl.gfs.${CDATE}
    ln -fs ${yyddd}${hh}00.gfs.t${hh}z.atmanl.nemsio siganl.gfs.${CDATE}
  fi
fi


echo "YYYYMMDDHH:  ${yyyymmdd}${hh}"
gdasfile=$GDASDIR/${yyddd}${hh}00.gdas.t${hh}z.atmanl.nemsio

if [[ -f $gdasfile ]]
then
  ln -fs $gdasfile gdas.t${hh}z.atmanl.nemsio
fi

echo $GDASDIR
echo $gdasfile


 


