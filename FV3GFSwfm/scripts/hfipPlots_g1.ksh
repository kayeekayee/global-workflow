#!/bin/ksh  -l

# -Example for FIM global model (with large-scale graphics only). Execute the following in the command line:
# /pan2/projects/hfipprd/Thiago.Quirino/HFIP-GRAPHICS/hfipGlobalModelGraphics.ksh 2012051412 FIM0 "ESRL/AMB" globalfimdata.txt TEMP/ FINAL/
#
# TRACKS are at:  /lfs4/HFIP/gsd-fv3-hfip/rtruns/UFS-CAMsuite/tracks/tctrk.atcf.2020071500.ucs1.txt

module load cnvgrib

# Print run parameters
ECHO=/bin/echo
yyyymmddhh=$(expr substr $yyyymmddhhmm 1 10)
${ECHO}
${ECHO} "hfipPlots_g1.ksh"
${ECHO}
${ECHO} "           T=${T}"
${ECHO} "           yyyymmddhhmm=${yyyymmddhhmm}"
${ECHO} "           FV3GFS_HOME=${FV3GFS_HOME}"
${ECHO} "           FV3GFS_RUN=${FV3GFS_RUN}"
${ECHO} "           FCST_INTERVAL=${FCST_INTERVAL}"
${ECHO} "           HFIP_SCRIPT=${HFIP_SCRIPT}"
${ECHO} "           TRACKFILE=${TRACKFILE}"
${ECHO} "           gribVersion=${gribVersion}"
${ECHO} "           ATCFNAME=${ATCFNAME}"
${ECHO} "           gribName=${gribName}"
${ECHO}

NDATE=${FV3GFS_HOME}/external/prod_util-1.0.18/exec/ndate
RM=/bin/rm
MKDIR=/bin/mkdir
MV=/bin/mv
FCST_TIME=`echo $((10#$T))`
echo FCST_TIME=$FCST_TIME
ATCF=`echo $ATCFNAME | tr "[a-z]" "[A-Z]"`

# Compute valid time and only continue if valid time is next month
curMonth=`echo $yyyymmddhh | cut -c 5-6`
vtime=`$NDATE $FCST_TIME $yyyymmddhh`
echo valid time:  $vtime
validMonth=`echo $vtime | cut -c 5-6`
echo current:  $curMonth, valid:  $validMonth
if [[ $curMonth -eq $validMonth ]]; then
  exit
fi

# Set up the work directory and cd into it
hfipDir="${FV3GFS_RUN}/hfipPlots"
rootDir="${FV3GFS_RUN}/hfipPlots_$T/"
tempDir="${rootDir}/TEMP/"
echo "hfipDir: $hfipDir"
if [[ ! -d $hfipDir ]]; then
  $MKDIR -p ${hfipDir}
  echo "making directory ${hfipDir}"
  status=$?
  if [ $status != 0 ]; then
    echo "error $status making $hfipDir"
    return $status
  fi
fi
echo "tempDir: $tempDir"
$RM -rf ${tempDir}
$MKDIR -p ${tempDir}
echo "making directory ${tempDir}"
status=$?
if [ $status != 0 ]; then
  echo "error $status making $tempDir"
  return $status
fi
finalDir="${rootDir}/FINAL/"
echo "finalDir: $finalDir"
$RM -rf ${finalDir}
$MKDIR -p ${finalDir}
echo "making directory ${finalDir}"
status=$?
if [ $status != 0 ]; then
  echo "error $status making $finalDir"
  return $status
fi
echo "gribName: $gribName"
if [[ -e $gribName ]]; then
  echo "converting to G1"
  cmd="cnvgrib -g21 ${gribName} ${gribName}.g1"
  echo $cmd
  $cmd
fi

# Get yyjjjHHMM
datestr=`echo ${yyyymmddhhmm} | sed 's/^\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1\/\2\/\3 \4\:\5/'`
yyjjjhhmm=`date +%y%j%H%M -d "${datestr}"`
#JKHgribVersion=$gribVersion

# run for each forecast hour, T
txtFile="${rootDir}/globalfv3data_${T}.txt"
echo "txtFile: $txtFile"
if [[ -e "$txtFile" ]]; then
   $RM -f $txtFile
fi
echo "Generating plots for forecast time ${T}"
dir_fcst="$(echo $T | sed 's/^[0]*//')"
#JKHgribName="$FV3GFS_RUN/post/fim/${yyjjjhhmm}0${T}"
#JKHgribName="$FV3GFS_RUN/post/fim/${yyjjjhhmm}0${T}.g2"
trackName="$TRACKFILE"
echo "trackName: $trackName"
echo "$FCST_TIME,$gribVersion,${gribName}.g1" >  $txtFile
status=$?
if [ $status != 0 ]; then
  echo "error $status writing to $txtFile"
  return $status
fi
if  [[ -s $trackName ]]; then
   echo "track exists"
   cmd="$HFIP_SCRIPT $yyyymmddhh $ATCF ESRL/GSL $txtFile $tempDir $finalDir $trackName"
else 
   cmd="$HFIP_SCRIPT $yyyymmddhh $ATCF ESRL/GSL $txtFile $tempDir $finalDir"
fi
echo "plot cmd: $cmd"
$cmd
status=$?
if [ $status != 0 ]; then
  echo "error $status running $cmd"
  return $status
fi
  (( t=t+${FCST_INTERVAL} ))


$RM -rf ${tempDir}
echo "moving $finalDir/*tgz to $hfipDir...."
$MV $finalDir/*.tgz $hfipDir
$RM -rf ${rootDir}

return 0
