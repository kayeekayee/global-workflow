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

###############################################################
# Archive data to HPSS
if [ $HPSSARCH = "YES" ]; then
###############################################################

  if [ $CDUMP = "gfs" ]; then
  
      ## nemsio files ##
      if [ -f *nemsio ]; then
        # archive nemsio files (gfs.t00z.atmfHHH.nemsio, gfs.t00z.sfcfHHH.nemsio, gfs.t00z.logfHHH.nemsio )
        htar -P -cvf $ATARDIR/$CDATE/gfs_nemsio.tar gfs.*nemsio
        status=$?
        if [ $status -ne 0 ]; then
          echo "HTAR $CDATE gfs_nemsio.tar failed"
          exit $status
        fi
      fi

      ## netcdf files ##
      if [ -f *nc ]; then
        # archive netcdf files (gfs.t00z.atmfHHH.nc, gfs.t00z.sfcfHHH.nc, gfs.t00z.logfHHH.txt )
        htar -P -cvf $ATARDIR/$CDATE/gfs_nc.tar gfs*.nc gfs.*log*.txt
        status=$?
        if [ $status -ne 0 ]; then
          echo "HTAR $CDATE gfs_nc.tar failed"
          exit $status
        fi
      fi
        
      # archive GRIB2 files (gfs.t00z.pgrb2.0p25.fHHH, gfs.t00z.pgrb2.0p50.fHHH) 
      # and tracker files (avno.t00z.cyclone.trackatcfunix, avnop.t00z.cyclone.trackatcfunix)
      htar -P -cvf $ATARDIR/$CDATE/gfs_pgrb2.tar gfs.*pgrb2.0p25* gfs.*pgrb2.0p5* avno*
      status=$?
      if [ $status -ne 0 ]; then
        echo "HTAR $CDATE gfs_pgrb2.tar failed"
        exit $status
      fi
      
  fi

###############################################################
fi  ##end of HPSS archive
###############################################################
