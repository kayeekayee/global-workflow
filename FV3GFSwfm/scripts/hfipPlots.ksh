#!/bin/ksh -l
#SBATCH -J HfipGlobalLargeScaleGFX
#SBATCH -D .
#SBATCH --partition=tjet,ujet,sjet
#SBATCH --ntasks=2
#SBATCH --mem=6G
#SBATCH --time=60
#SBATCH -q batch
#SBATCH -A gsd-fv3-dev

# -Example for FIM global model (with large-scale graphics only). Execute the following in the command line:
# /pan2/projects/hfipprd/Thiago.Quirino/HFIP-GRAPHICS/hfipGlobalModelGraphics.ksh 2012051412 FIM0 "ESRL/AMB" globalfimdata.txt TEMP/ FINAL/
#
# TRACKS are at:  /lfs4/HFIP/gsd-fv3-hfip/rtruns/UFS-CAMsuite/tracks/tctrk.atcf.2020071500.ucs1.txt

module load cnvgrib
#

# Print run parameters
ECHO=/bin/echo
yyyymmddhh=$(expr substr $yyyymmddhhmm 1 10)
${ECHO}
${ECHO} "hfipPlots.ksh"
${ECHO}
${ECHO} "           T=${T}"
${ECHO} "           yyyymmddhhmm=${yyyymmddhhmm}"
${ECHO} "           FV3GFS_RUN=${FV3GFS_RUN}"
${ECHO} "           FCST_INTERVAL=${FCST_INTERVAL}"
${ECHO} "           HFIP_SCRIPT=${HFIP_SCRIPT}"
${ECHO} "           TRACKFILE=${TRACKFILE}"
${ECHO} "           ATCFNAME=${ATCFNAME}"
${ECHO} "           g2file=${g2file}"
${ECHO}

RM=/bin/rm
MKDIR=/bin/mkdir
MV=/bin/mv
FCST_TIME=`echo $((10#$T))`
echo FCST_TIME=$FCST_TIME
ATCF=`echo $ATCFNAME | tr "[a-z]" "[A-Z]"`

# Set up the work directory and cd into it
hfipDir="${FV3GFS_RUN}/hfipPlots"
rootDir="${FV3GFS_RUN}/hfipPlots_$T/"
tempDir="${rootDir}/TEMP/"
echo "hfipDir: $hfipDir"
if [[ ! -d $hfipDir ]]; then
  $MKDIR -p ${hfipDir}
  status=$?
  if [ $status != 0 ]; then
    echo "error $status making $hfipDir"
    return $status
  fi
fi
echo "tempDir: $tempDir"
$RM -rf ${tempDir}
$MKDIR -p ${tempDir}
status=$?
if [ $status != 0 ]; then
  echo "error $status making $tempDir"
  return $status
fi
finalDir="${rootDir}/FINAL/"
echo "finalDir: $finalDir"
$RM -rf ${finalDir}
$MKDIR -p ${finalDir}
status=$?
if [ $status != 0 ]; then
  echo "error $status making $finalDir"
  return $status
fi

# Get yyjjjHHMM
datestr=`echo ${yyyymmddhhmm} | sed 's/^\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1\/\2\/\3 \4\:\5/'`
yyjjjhhmm=`date +%y%j%H%M -d "${datestr}"`
gribVersion=2

# run for each forecast hour, T
txtFile="${rootDir}/globalfv3data_${T}.txt"
echo "txtFile: $txtFile"
if [[ -e "$txtFile" ]]; then
   $RM -f $txtFile
fi
echo "Generating plots for forecast time ${T}"
dir_fcst="$(echo $T | sed 's/^[0]*//')"
gribName="$FV3GFS_RUN/${g2file}"
echo "gribName: $gribName"
trackName="$TRACKFILE"
echo "trackName: $trackName"
echo "$FCST_TIME,$gribVersion,$gribName" >  $txtFile
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
