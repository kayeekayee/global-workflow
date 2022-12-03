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
## ATCFNAME  : atcf track identifier
## COMPONENT : component (atmos/wave)
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

COMIN="$ROTDIR/$CDUMP.$PDY/$cyc/$COMPONENT"
cd $COMIN

YYYY=`echo $PDY|cut -c1-4`
###############################################################
# Archive data to HPSS
if [ $HPSSARCH = "YES" ]; then
###############################################################

  if [ $CDUMP = "gfs" ]; then
  
      ## nemsio files ##
      if [ -f *nemsio ]; then
        # archive nemsio files (gfs.t00z.atmfHHH.nemsio, gfs.t00z.sfcfHHH.nemsio, gfs.t00z.logfHHH.nemsio )
        htar -P -cvf $ATARDIR/$YYYY/$CDATE/gfs_nemsio.tar gfs.*nemsio
        status=$?
        if [ $status -ne 0 ]; then
          echo "HTAR $CDATE gfs_nemsio.tar failed"
          exit $status
        fi
      fi

      ## netcdf files ##
#JKH      if [ -f *f???.nc ]; then
      if [ -f g*atmf000.nc ]; then
        # archive netcdf files (gfs.t00z.atmfHHH.nc, gfs.t00z.sfcfHHH.nc, gfs.t00z.logfHHH.txt )
        htar -P -cvf $ATARDIR/$YYYY/$CDATE/gfs_nc.tar gfs*.nc gfs.*log*.txt
        status=$?
        if [ $status -ne 0 ]; then
          echo "HTAR $CDATE gfs_nc.tar failed"
          exit $status
        fi
      fi
        
      # archive GRIB2 files (gfs.t00z.pgrb2.0p25.fHHH, gfs.t00z.pgrb2.0p50.fHHH) 
      #   and tracker files (tctrk.atcf.YYYYMMDDHH.gcp1.txt)
#JKH      if [ -f tctrk.atcf.${CDATE}.${ATCFNAME}.txt ]; then
#JKH        htar -P -cvf $ATARDIR/$YYYY/$CDATE/gfs_pgrb2.tar gfs.*pgrb2.0p25* gfs.*pgrb2.0p5* tctrk.atcf.${CDATE}.${ATCFNAME}.txt
#JKH      else
#JKH        htar -P -cvf $ATARDIR/$YYYY/$CDATE/gfs_pgrb2.tar gfs.*pgrb2.0p25* gfs.*pgrb2.0p5* 
#JKH      fi
#JKH      status=$?
#JKH      if [ $status -ne 0 ]; then
#JKH        echo "HTAR $CDATE gfs_pgrb2.tar failed"
#JKH        exit $status
#JKH      fi
      
  fi

###############################################################
fi  ##end of HPSS archive
###############################################################
