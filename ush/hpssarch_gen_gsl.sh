#! /usr/bin/env bash

###################################################
# Fanglin Yang, 20180318
# --create bunches of files to be archived to HPSS
# Judy Henderson, 20230714
# -- modified for GSL
# -- only echo name of file if file exists
###################################################
source "${HOMEgfs}/ush/preamble.sh"

type=${1:-gfs}                ##gfs

ARCH_GAUSSIAN=${ARCH_GAUSSIAN:-"YES"}
ARCH_GAUSSIAN_FHMAX=${ARCH_GAUSSIAN_FHMAX:-36}
ARCH_GAUSSIAN_FHINC=${ARCH_GAUSSIAN_FHINC:-6}

echo "JKH:  echo ATCFNAME:  $ATCFNAME"  

#-----------------------------------------------------
if [[ ${type} = "gfs" ]]; then
#-----------------------------------------------------
  FHMIN_GFS=${FHMIN_GFS:-0}
  FHMAX_GFS=${FHMAX_GFS:-384}
  FHOUT_GFS=${FHOUT_GFS:-3}
  FHMAX_HF_GFS=${FHMAX_HF_GFS:-120}
  FHOUT_HF_GFS=${FHOUT_HF_GFS:-1}

  rm -f gfs_pgrb2.txt
  rm -f gfs_ics.txt
  touch gfs_pgrb2.txt
  touch gfs_ics.txt

  if [[ ${ARCH_GAUSSIAN} = "YES" ]]; then
    rm -f gfs_nc.txt
    touch gfs_nc.txt

  fi

  head="gfs.t${cyc}z."

  fh=0
  while (( fh <= ARCH_GAUSSIAN_FHMAX )); do
    fhr=$(printf %03i "${fh}")
    {
      [[ -s ${COM_ATMOS_HISTORY}/${head}atmf${fhr}.nc ]] && echo "${COM_ATMOS_HISTORY/${ROTDIR}\//}/${head}atmf${fhr}.nc"
      [[ -s ${COM_ATMOS_HISTORY}/${head}sfcf${fhr}.nc ]] && echo "${COM_ATMOS_HISTORY/${ROTDIR}\//}/${head}sfcf${fhr}.nc"
    } >> gfs_nc.txt
    fh=$((fh+ARCH_GAUSSIAN_FHINC))
  done

  #..................
  # Exclude the gfsarch.log file, which will change during the tar operation
  #  This uses the bash extended globbing option
  {
    echo "./logs/${PDY}${cyc}/gfs!(arch).log"
    [[ -s ${COM_ATMOS_HISTORY}/input.nml ]] && echo "${COM_ATMOS_HISTORY/${ROTDIR}\//}/input.nml"

#JKH    echo "${COM_ATMOS_GRIB_0p25/${ROTDIR}\//}/${head}pgrb2.0p25.anl"
#JKH    echo "${COM_ATMOS_GRIB_0p25/${ROTDIR}\//}/${head}pgrb2.0p25.anl.idx"

    #Only generated if there are cyclones to track
    cyclone_file="tctrk.atcf.${PDY}${cyc}.${ATCFNAME}.txt"
    [[ -s ${COM_ATMOS_TRACK}/${cyclone_file} ]] && echo "${COM_ATMOS_TRACK/${ROTDIR}\//}/${cyclone_file}"

  } >> gfs_pgrb2.txt

  fh=0
  while (( fh <= FHMAX_GFS )); do
    fhr=$(printf %03i "${fh}")

    {
      if [[ -s ${COM_ATMOS_GRIB_0p25}/${head}pgrb2.0p25.f${fhr} ]]; then
        echo "${COM_ATMOS_GRIB_0p25/${ROTDIR}\//}/${head}pgrb2.0p25.f${fhr}"
        echo "${COM_ATMOS_GRIB_0p25/${ROTDIR}\//}/${head}pgrb2.0p25.f${fhr}.idx"
        echo "${COM_ATMOS_HISTORY/${ROTDIR}\//}/${head}atm.logf${fhr}.txt"
      fi
    } >> gfs_pgrb2.txt


    inc=${FHOUT_GFS}
    if (( FHMAX_HF_GFS > 0 && FHOUT_HF_GFS > 0 && fh < FHMAX_HF_GFS )); then
      inc=${FHOUT_HF_GFS}
    fi

    fh=$((fh+inc))
  done

  #..................
  {
    echo "${COM_ATMOS_INPUT/${ROTDIR}\//}/chgres_done"
    echo "${COM_ATMOS_INPUT/${ROTDIR}\//}/gfs_ctrl.nc"
    echo "${COM_ATMOS_INPUT/${ROTDIR}\//}/gfs_data.tile1.nc"
    echo "${COM_ATMOS_INPUT/${ROTDIR}\//}/gfs_data.tile2.nc"
    echo "${COM_ATMOS_INPUT/${ROTDIR}\//}/gfs_data.tile3.nc"
    echo "${COM_ATMOS_INPUT/${ROTDIR}\//}/gfs_data.tile4.nc"
    echo "${COM_ATMOS_INPUT/${ROTDIR}\//}/gfs_data.tile5.nc"
    echo "${COM_ATMOS_INPUT/${ROTDIR}\//}/gfs_data.tile6.nc"
    echo "${COM_ATMOS_INPUT/${ROTDIR}\//}/sfc_data.tile1.nc"
    echo "${COM_ATMOS_INPUT/${ROTDIR}\//}/sfc_data.tile2.nc"
    echo "${COM_ATMOS_INPUT/${ROTDIR}\//}/sfc_data.tile3.nc"
    echo "${COM_ATMOS_INPUT/${ROTDIR}\//}/sfc_data.tile4.nc"
    echo "${COM_ATMOS_INPUT/${ROTDIR}\//}/sfc_data.tile5.nc"
    echo "${COM_ATMOS_INPUT/${ROTDIR}\//}/sfc_data.tile6.nc"
  } >> gfs_ics.txt


#-----------------------------------------------------
fi   ##end of gfs
#-----------------------------------------------------

exit 0

