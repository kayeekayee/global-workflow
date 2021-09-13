#!/bin/ksh -x

###############################################################
## Abstract:
## Archive driver script
## RUN_ENVIR : runtime environment (emc | nco)
## HOMEgfs   : /full/path/to/workflow
## EXPDIR : /full/path/to/config/files
## CDATE  : current analysis date (YYYYMMDDHH)
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
configs="base arch"
for config in $configs; do
    . $EXPDIR/config.${config}
    status=$?
    [[ $status -ne 0 ]] && exit $status
done

COMIN="$ROTDIR/$CDUMP.$PDY/$cyc"
cd $COMIN

YYYY=`echo $PDY|cut -c1-4`
###############################################################
# Archive data to HPSS
if [ $HPSSARCH = "YES" ]; then
###############################################################

  if [ $CDUMP = "gfs" ]; then
  
      # archive nemsio files (gfs.t00z.atmfHHH.nemsio, gfs.t00z.sfcfHHH.nemsio, gfs.t00z.logfHHH.nemsio )
      htar -P -cvf $ATARDIR/$YYYY/$CDATE/${CDATE}_nemsio.tar *nemsio*
      status=$?
      if [ $status -ne 0 ]; then
        echo "HTAR $CDATE gfs_nemsio.tar failed"
        exit $status
      fi
      
      # archive RESTART directory 
      htar -P -cvf $ATARDIR/$YYYY/$CDATE/${CDATE}_restart.tar RESTART
      status=$?
      if [ $status -ne 0 ]; then
        echo "HTAR $CDATE gfs_pgrb2.tar failed"
        exit $status
      fi

      # archive GRIB2 files (gfs.t00z.pgrb2.0p25.fHHH, gfs.t00z.pgrb2.0p50.fHHH)
      htar -P -cvf $ATARDIR/$YYYY/$CDATE/${CDATE}_pgrb2.tar *pgrb2*
      status=$?
      if [ $status -ne 0 ]; then
        echo "HTAR $CDATE gfs_pgrb2.tar failed"
        exit $status
      fi
      
      # archive NCL files (files.zip)
      htar -P -cvf $ATARDIR/$YYYY/$CDATE/${CDATE}_ncl.tar ncl/*/files.zip
      status=$?
      if [ $status -ne 0 ]; then
        echo "HTAR $CDATE gfs_pgrb2.tar failed"
        exit $status
      fi

      # archive regrid directory from RUNDIRS
      cd ${RUNDIR}/${CDATE}/gfs
      htar -P -cvf $ATARDIR/$YYYY/$CDATE/${CDATE}_regrid.tar regrid
      status=$?
      if [ $status -ne 0 ]; then
        echo "HTAR $CDATE regrid.tar failed"
        exit $status
      fi

  fi
      
###############################################################
fi  ##end of HPSS archive
###############################################################
