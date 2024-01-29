#! /usr/bin/env bash

source "${HOMEgfs}/ush/preamble.sh"

###############################################################
# Source FV3GFS workflow modules
source "${HOMEgfs}/ush/load_fv3gfs_modules.sh"
status=$?
(( status != 0 )) && exit "${status}"

export job="tracker"
export jobid="${job}.$$"

###############################################################
# Execute the JJOB

"${HOMEgfs}/jobs/JGFS_ATMOS_CYCLONE_TRACKER"

# GSL - rename tracker file and change AVNO to $ACTFNAME         ## JKH
export TRACKDIR="${ROTDIR}/../../tracks"
if [ ! -d $TRACKDIR ]; then mkdir $TRACKDIR ; fi
typeset -u ucatcf=$ATCFNAME
YMD=${PDY} HH=${cyc} generate_com -x COM_ATMOS_TRACK
if [ -f ${COM_ATMOS_TRACK}/avnop.t${cyc}z.cyclone.trackatcfunix ]; then
  cat $COM_ATMOS_TRACK/avnop.t${cyc}z.cyclone.trackatcfunix | sed s:AVNO:${ucatcf}:g > $TRACKDIR/tctrk.atcf.${CDATE}.${ATCFNAME}.txt
  cp -p $TRACKDIR/tctrk.atcf.${CDATE}.${ATCFNAME}.txt $COM_ATMOS_TRACK/tctrk.atcf.${CDATE}.${ATCFNAME}.txt
  rm -f $COM_ATMOS_TRACK/avnop.t${cyc}z.cyclone.trackatcfunix $COM_ATMOS_TRACK/avno.t${cyc}z.cyclone.trackatcfunix
  echo "$COM_ATMOS_TRACK/avno*.t${cyc}z.cyclone.trackatcfunix deleted...."
else
  echo "no track file created...."
fi

status=$?

exit "${status}"
