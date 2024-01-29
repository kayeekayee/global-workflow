#! /usr/bin/env bash

###################################################
# Fanglin Yang, 20180318
# --create bunches of files to be archived to HPSS
# Judy Henderson, 20240126
# --modified for GSL
# --only echo name of file if file exists
# --assume we only run cold starts
###################################################
source "${HOMEgfs}/ush/preamble.sh"

type=${1:-gfs}                ##gfs

ARCH_GAUSSIAN=${ARCH_GAUSSIAN:-"YES"}
ARCH_GAUSSIAN_FHMAX=${ARCH_GAUSSIAN_FHMAX:-36}
ARCH_GAUSSIAN_FHINC=${ARCH_GAUSSIAN_FHINC:-6}

# Set whether to archive downstream products
DO_DOWN=${DO_DOWN:-"NO"}
if [[ ${DO_BUFRSND} = "YES" ]]; then
  export DO_DOWN="YES"
fi

#-----------------------------------------------------
if [[ ${type} = "gfs" ]]; then
#-----------------------------------------------------
  FHMIN_GFS=${FHMIN_GFS:-0}
  FHMAX_GFS=${FHMAX_GFS:-384}
  FHOUT_GFS=${FHOUT_GFS:-3}
  FHMAX_HF_GFS=${FHMAX_HF_GFS:-120}
  FHOUT_HF_GFS=${FHOUT_HF_GFS:-1}

  rm -f "${DATA}/gfs_pgrb2.txt"
  rm -f "${DATA}/gfs_ics.txt"
  touch "${DATA}/gfs_pgrb2.txt"
  touch "${DATA}/gfs_ics.txt"

  if [[ ${ARCH_GAUSSIAN} = "YES" ]]; then
    rm -f "${DATA}/gfs_nc.txt"
    touch "${DATA}/gfs_nc.txt"
  fi

  head="gfs.t${cyc}z."

  if [[ ${ARCH_GAUSSIAN} = "YES" ]]; then
    fh=0
    while (( fh <= ARCH_GAUSSIAN_FHMAX )); do
      fhr=$(printf %03i "${fh}")
      {
        [[ -s ${COM_ATMOS_HISTORY}/${head}atmf${fhr}.nc ]] && echo "${COM_ATMOS_HISTORY/${ROTDIR}\//}/${head}atmf${fhr}.nc"
        [[ -s ${COM_ATMOS_HISTORY}/${head}sfcf${fhr}.nc ]] && echo "${COM_ATMOS_HISTORY/${ROTDIR}\//}/${head}sfcf${fhr}.nc"
      } >> "${DATA}/gfs_nc.txt"
      fh=$((fh+ARCH_GAUSSIAN_FHINC))
    done
  fi

  #..................
  # Exclude the gfsarch.log file, which will change during the tar operation
  #  This uses the bash extended globbing option
  {
    echo "./logs/${PDY}${cyc}/gfs!(arch).log"
    [[ -s ${COM_ATMOS_HISTORY}/input.nml ]] && echo "${COM_ATMOS_HISTORY/${ROTDIR}\//}/input.nml"

    #Only generated if there are cyclones to track
    cyclone_file="tctrk.atcf.${PDY}${cyc}.${ATCFNAME}.txt"
    [[ -s ${COM_ATMOS_TRACK}/${cyclone_file} ]] && echo "${COM_ATMOS_TRACK/${ROTDIR}\//}/${cyclone_file}"

  } >> "${DATA}/gfs_pgrb2.txt"

  fh=0
  while (( fh <= FHMAX_GFS )); do
    fhr=$(printf %03i "${fh}")

    if [[ ${ARCH_GAUSSIAN} = "YES" ]]; then
      {
      if [[ -s ${COM_ATMOS_GRIB_0p25}/${head}pgrb2.0p25.f${fhr} ]]; then
        echo "${COM_ATMOS_GRIB_0p25/${ROTDIR}\//}/${head}pgrb2.0p25.f${fhr}"
        echo "${COM_ATMOS_GRIB_0p25/${ROTDIR}\//}/${head}pgrb2.0p25.f${fhr}.idx"
        echo "${COM_ATMOS_HISTORY/${ROTDIR}\//}/${head}atm.logf${fhr}.txt"
      fi
    } >> "${DATA}/gfs_pgrb2.txt"

#JKH    {
#JKH      if [[ -s "${COM_ATMOS_GRIB_0p50}/${head}pgrb2.0p50.f${fhr}" ]]; then
#JKH         echo "${COM_ATMOS_GRIB_0p50/${ROTDIR}\//}/${head}pgrb2.0p50.f${fhr}"
#JKH         echo "${COM_ATMOS_GRIB_0p50/${ROTDIR}\//}/${head}pgrb2.0p50.f${fhr}.idx"
#JKH      fi
#JKH      if [[ -s "${COM_ATMOS_GRIB_1p00}/${head}pgrb2.1p00.f${fhr}" ]]; then
#JKH         echo "${COM_ATMOS_GRIB_1p00/${ROTDIR}\//}/${head}pgrb2.1p00.f${fhr}"
#JKH         echo "${COM_ATMOS_GRIB_1p00/${ROTDIR}\//}/${head}pgrb2.1p00.f${fhr}.idx"
#JKH      fi
#JKH    } >> "${DATA}/gfsb.txt"

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
  } >> "${DATA}/gfs_ics.txt"

#-----------------------------------------------------
fi   ##end of gfs
#-----------------------------------------------------

#JKHexit 0
