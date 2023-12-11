#! /usr/bin/env bash

####  UNIX Script Documentation Block
#
# Script name:         tropcy_relocate.sh
# Script description:  Performs tropical cyclone relocation processing
#
# Author:        D.A. Keyser        Org: NP22         Date: 2007-04-05
#
# Abstract: This script attempts to relocate tropical cyclones in the Global
#   guess fields.  It points to tropical cyclone location records (tcvitals) as
#   input files.  The tcvitals file is normally generated by the previous
#   SYNDAT_QCTROPCY program.  As part of this relocation processing, global
#   sigma guess files valid 3-hours before, 3-hours after, and at the center
#   date/time for the relocation processing are generated.  These files are
#   used later by the Global analysis.  In Global and Regional networks, this
#   new "relocated" global guess file can later be encoded into the PREPBUFR
#   file for use by the quality control programs in the PREPBUFR processing.
#   Here the relocated guess is valid at the center date/time for the PREPBUFR
#   processing).  This script has been designed to be executed by either an
#   operational job script, a test job script, a parallel job script, or a
#   stand-alone batch run initiated by a user.
# 
# Script history log:
# 2006-06-12  Dennis A. Keyser -- Original version for implementation - split
#      off from USH script prepobs_makeprepbufr.sh, this was done to allow
#      the new TROPCY_QC_RELOC job executing this script (which runs after
#      TROPCY_QC_RELOC performs qctropcy processing, moved from the DUMP job)
#      to run at the same time as the DUMP job in order to speed up overall obs
#      processing and remove variability in the subsequent PREP job (i.e., the
#      PREP job had run faster when no tropical cyclones were present)
# 2006-10-19  R. Treadon - replace XLFUNIT_21,22,23,53,56,59 with soft links
#      to avoid conflict with new relocation code which explicitly opens
#      these units to specific filenames.  Also remove fort.12 reference
#      since no longer necessary.
# 2007-04-05  Dennis A. Keyser -- Store pathname to original center-time sigma
#      guess (input to relocation) in /com (with .pre-relocate. qualifier) so
#      it can be identified later
# 2012-08-01  Luke Lin -- alerts inform.relocate, tcvitals.relocate, tropcy_relocation_status
# 2012-12-03  J. Woollen -- transitioned to WCOSS system. Introduced mpi version of the      
#      relocate code which precesses three backgrounds in one run. Removed the older
#      poe/cmdfile parallelism from the script.
# 2013-10-11  D. Stokes -- Modified some variable names for reorganization.
#
# Usage:  tropcy_relocate.sh yyyymmddhh
#
#   Input script positional parameters:
#     1             String indicating the center date/time for the relocation
#                   processing <yyyymmddhh> - if missing, then this time
#                   is obtained from the /com/date/$cycle file unless
#                   the imported variable MACHINE=sgi in which case the
#                   script exits abnormally
#
#   Imported Shell Variables:
#
#     These must ALWAYS be exported to this script by the parent script --
#
#     NET           String indicating system network (either "gfs", "gdas" or
#                   "nam")
#                   NOTE: NET is changed to gdas in the parent Job script for
#                         the RUN=gdas1 (was gfs - NET remains gfs for RUN=gfs)
#     RUN           String indicating model run (either "gfs", "gdas1", "nam",
#                   or "ndas")
#     cycle         String indicating the center cycle hour for relocation
#                   processing {"txxz", where xx is two-digit hour of the day
#                   (UTC)}
#                   {NOTE: This is required ONLY if input script positional
#                          parameter 1 is missing (see above)}
#     DATA          String indicating the working directory path (usually a
#                   temporary location)
#     COMSP         String indicating the directory/filename path to:
#                     -input tropical cyclone location (tcvitals) file output
#                       from previous qctropcy processing
#                     -tropical cyclone relocation (tcvitals.relocate.$tmmark)
#                       file and information (inform.relocate.$tmmark) file,
#                       both output from this processing
#                   (e.g., "/com/gfs/prod/gdas.20060612/gdas1.t12z.")
#
#     These will be set to their default value in this script if not exported
#      to this script by the parent script --
#
#     MACHINE       String indicating machine on which this job is running
#                   Default is "$(hostname -s | cut -c 1-3)"
#     envir         String indicating environment under which job runs ('prod'
#                   or 'test')
#                   Default is "prod"
#     HOMEALL       String indicating parent directory path for some or 
#                   all files under which job runs.
#                   If the imported variable MACHINE!=sgi, then the default is
#                   "/nw${envir}"; otherwise the default is
#                   "/disk1/users/snake/prepobs"
#     HOMERELO      String indicating parent directory path for relocation
#                   specific files.  (May be under HOMEALL)
#     envir_getges  String indicating environment under which GETGES utility
#                   ush runs (see documentation in $USHGETGES/getges.sh for
#                   more information)
#                   Default is "$envir"
#     network_getges
#                   String indicating job network under which GETGES utility
#                   ush runs (see documentation in $USHGETGES/getges.sh for
#                   more information)
#                   Default is "global" unless the center relocation processing
#                   date/time is not a multiple of 3-hrs, then the default is
#                   "gfs"
#     pgmout        String indicating file containing standard output (output
#                   always contatenated onto this file)
#                   Default is "/dev/null"
#     tstsp         String indicating the directory/filename path to input
#                   tropical cyclone location (tcvitals) file output from
#                   previous qctropcy processing that is to override the
#                   corresponding file in $COMSP (this should be imported with
#                   the same naming convention as $COMSP; e.g.,
#                   "/stmp/wx22dk/test_dump/ndas.20060612/ndas.t12z." -
#                   (if tstsp is not imported, the default is used and no
#                   overriding file would exist; if tstsp is imported then any
#                   file found would override the corresponding file in $COMSP)
#                   Default is "/tmp/null/"
#     tmmark      - string indicating hour for center relocation processing
#                   date/time relative to the analysis time embedded in $tstsp
#                   or $COMSP (e.g., "tm12", "tm09", "tm06", "tm03", "tm00")
#                   Default is "tm00"
#     POE_OPTS      String indicating options to use with poe command
#                   Default is "-pgmmodel mpmd -ilevel 2 -labelio yes \
#                   -stdoutmode ordered"
#     USHGETGES     String indicating directory path for GETGES utility ush
#                   file
#     USHRELO       String indicating directory path for RELOCATE ush files
#                   Default is "${HOMERELO}/ush"
#     EXECRELO      String indicating directory path for RELOCATE executables
#                   Default is "${HOMERELO}/exec"
#     FIXRELO       String indicating directory path for RELOCATE data fix-
#                   field files
#                   Default is "${HOMERELO}/fix"
#     EXECUTIL      String indicating directory path for utility program
#                   executables
#                   If the imported variable MACHINE!=sgi, then the default is
#                   "/nwprod/util/exec"; otherwise the default is
#                   "${HOMEALL}/util/exec"
#     RELOX         String indicating executable path for RELOCATE_MV_NVORTEX
#                   program 
#                   Default is "$EXECRELO/relocate_mv_nvortex"
#     SUPVX         String indicating executable path for SUPVIT utility
#                   program
#                   Default is "$EXECUTIL/supvit.x"
#     GETTX         String indicating executable path for GETTRK utility
#                   program
#                   Default is "$EXECUTIL/gettrk"
#     BKGFREQ       Frequency of background files for relocation
#                   Default is "3" 
#     SENDDBN       String when set to "YES" alerts output files to $COMSP
#     NDATE         String indicating executable path for NDATE utility program
#                   Default is "$EXECUTIL/ndate"
#
#     These do not have to be exported to this script.  If they are, they will
#      be used by the script.  If they are not, they will be skipped
#      over by the script.
#
#   Exported Shell Variables:
#     CDATE10       String indicating the center date/time for the relocation
#                   processing <yyyymmddhh>
#     CMODEL        String indicating model on which hurricane tracker should
#                   run (this is passed to child script
#                   tropcy_relocate_extrkr.sh - if "$CMODEL" is not set here,
#                   it defaults to "$RUN")
#   
#
#   Modules and files referenced:
#                  Herefile: RELOCATE_GES
#                  $USHRELO/tropcy_relocate_extrkr.sh
#                  $USHGETGES/getges.sh
#                  $NDATE (here and in child script
#                        $USHRELO/tropcy_relocate_extrkr.sh)
#                  /usr/bin/poe
#                  postmsg
#                  $DATA/prep_step (here and in child script
#                        $USHRELO/tropcy_relocate_extrkr.sh)
#                  $DATA/err_exit (here and in child script
#                        $USHRELO/tropcy_relocate_extrkr.sh)
#                  $DATA/err_chk (here and in child script
#                        $USHRELO/tropcy_relocate_extrkr.sh)
#          NOTE: The last three scripts above are NOT REQUIRED utilities.
#                If $DATA/prep_step not found, a scaled down version of it is
#                executed in-line.  If $DATA/err_exit or $DATA/err_chk are not
#                found and a fatal error has occurred, then the script calling
#                it will kill itself and exit with a 555 return code causing
#                all parent scripts to be killed.
#
#     programs   :
#          RELOCATE_MV_NVORTEX - executable $RELOX
#                                 T126 GRIB global land/sea mask:
#                                          $FIXRELO/global_slmask.t126.grb
#          SUPVIT               - executable $SUPVX
#          GETTRK               - executable $GETTX
#
# Remarks:
#
#   Condition codes
#      0 - no problem encountered
#     >0 - some problem encountered
#
# Attributes:
#   Language: POSIX shell
#   Machine: IBM-SP, SGI
#
####

source "$HOMEgfs/ush/preamble.sh"

MACHINE=${MACHINE:-$(hostname -s | cut -c 1-3)}

export OPSROOT=${OPSROOT:-/lfs/h1/ops/prod}
GRIBVERSION=${GRIBVERSION:-"grib2"}

if [ ! -d $DATA ] ; then mkdir -p $DATA ;fi

cd $DATA

qid=$$


#  obtain the center date/time for relocation processing
#  -----------------------------------------------------

if [ $# -ne 1 ] ; then
   if [ $MACHINE != sgi ]; then
#      cp ${COMROOT}/date/$cycle ncepdate
#      err0=$?
      ncepdate=${PDY}${cyc}      
      CDATE10=$(cut -c7-16 ncepdate)
   else
      err0=1
   fi
else 
   CDATE10=$1
   if [ "${#CDATE10}" -ne '10' ]; then
      err0=1
   else
      cycle=t$(echo $CDATE10|cut -c9-10)z
      err0=0
   fi
fi

if test $err0 -ne 0
then
#  problem with obtaining date record so exit
   set +x
   echo
   echo "problem with obtaining date record;"
   echo "ABNORMAL EXIT!!!!!!!!!!!"
   echo
   set_trace
   if [ -s $DATA/err_exit ]; then
      $DATA/err_exit
   else
######kill -9 ${qid}
      exit 555
   fi
   exit 9
fi

pdy=$(echo $CDATE10|cut -c1-8)
cyc=$(echo $CDATE10|cut -c9-10)
modhr=$(expr $cyc % 3)

set +x
echo
echo "CENTER DATE/TIME FOR RELOCATION PROCESSING IS $CDATE10"
echo
set_trace

#----------------------------------------------------------------------------

#  Create variables needed for this script and its children
#  --------------------------------------------------------

envir=${envir:-prod}

if [ $MACHINE != sgi ]; then
   HOMEALL=${HOMEALL:-$OPSROOT}
else
   HOMEALL=${HOMEALL:-/disk1/users/snake/prepobs}
fi

HOMERELO=${HOMERELO:-${shared_global_home}}

envir_getges=${envir_getges:-$envir}
if [ $modhr -eq 0 ]; then
   network_getges=${network_getges:-global}
else
   network_getges=${network_getges:-gfs}
fi

pgmout=${pgmout:-/dev/null}

tstsp=${tstsp:-/tmp/null/}
tmmark=${tmmark:-tm00}

USHRELO=${USHRELO:-${HOMERELO}/ush}
##USHGETGES=${USHGETGES:-/nwprod/util/ush}
##USHGETGES=${USHGETGES:-${HOMERELO}/ush}
USHGETGES=${USHGETGES:-${USHRELO}}

EXECRELO=${EXECRELO:-${HOMERELO}/exec}

FIXRELO=${FIXRELO:-${HOMERELO}/fix}

RELOX=${RELOX:-$EXECRELO/relocate_mv_nvortex}

export BKGFREQ=${BKGFREQ:-1}

SUPVX=${SUPVX:-$EXECRELO/supvit.x}
GETTX=${GETTX:-$EXECRELO/gettrk}

################################################
# EXECUTE TROPICAL CYCLONE RELOCATION PROCESSING
################################################

#  attempt to perform tropical cyclone relocation
#  ----------------------------------------------

echo "Attempt to perform tropical cyclone relocation for $CDATE10"

if [ $modhr -ne 0 ]; then

#  if center date/time for relocation processing isn't a multiple of 3-hrs, exit
#  -----------------------------------------------------------------------------

   set +x
   echo
   echo "cannot perform tropical cyclone processing because cycle hour is \
not a multiple of 3-hrs;"
   echo "ABNORMAL EXIT!!!!!!!!!!!"
   echo
   set_trace
   if [ -s $DATA/err_exit ]; then
      $DATA/err_exit
   else
      exit 555
   fi
   exit 9
fi

for fhr in 6 12 ;do
   if [ ! -s tcvitals.m${fhr} ]; then   # This should never exist, right ????

#  create a null tcvitals file for 06 or 12 hours ago
#  use getges to overwrite with any found

      >tcvitals.m${fhr}
      set +x
      echo
echo "VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV"
echo "       Get TCVITALS file valid for -$fhr hrs relative to center"
echo "                    relocation processing date/time"
echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
      echo
      set_trace
      $USHGETGES/getges.sh -e $envir_getges -n $network_getges \
       -v $CDATE10 -f $fhr -t tcvges tcvitals.m${fhr}
      set +x
      echo
echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
      echo
      set_trace
   fi
done

#  Next line needed to assure that only an analysis file will have the
#   relocation codes run on it

export CMODEL=gdas
if [ "$GRIBVERSION" = "grib1" ]; then
  export gribver=1
  pgpref=pgbg
else
  export gribver=2                 # default
  pgpref=pg2g
fi

for fhr in $( seq -6 $BKGFREQ 3 ) ; do

   if [ $fhr -lt 0 ]; then
      tpref=m$(expr $fhr \* -1)
   elif [ $fhr -eq 0 ]; then
      tpref=es
   elif [ $fhr -gt 0 ]; then
      tpref=p$fhr
   fi

   sges=sg${tpref}prep
   [[ $fhr -lt -3 ]]&&sges=NULL
   echo $sges
#   stype=sigg${tpref}
   stype=natg${tpref}
   [[ $RUN = cdas1 ]] && stype=sigg${tpref} ## for cfs
   pges=pg${tpref}prep
   ptype=${pgpref}${tpref}

   if [ $sges != NULL -a ! -s $sges ]; then
      set +x
      echo
echo "VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV"
echo "     Get global sigma GUESS valid for $fhr hrs relative to center"
echo "                    relocation processing date/time"
echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
      echo
      set_trace
      $USHGETGES/getges.sh -e $envir_getges -n $network_getges \
       -v $CDATE10 -t $stype $sges
      errges=$?
      if test $errges -ne 0; then
#  problem obtaining global sigma first guess so exit
         set +x
         echo
         echo "problem obtaining global sigma guess valid $fhr hrs relative \
to center relocation date/time;"
         echo "ABNORMAL EXIT!!!!!!!!!!!"
         echo
         set_trace
         if [ -s $DATA/err_exit ]; then
            $DATA/err_exit
         else
############kill -9 ${qid}
            exit 555
         fi
         exit 9
      fi

#  For center time sigma guess file obtained via getges, store pathname from
#   getges into ${COM_OBS}/${RUN}.${cycle}.sgesprep_pre-relocate_pathname.$tmmark and, for now,
#   also in ${COM_OBS}/${RUN}.${cycle}.sgesprep_pathname.$tmmark - if relocation processing stops
#   due to an error or due to no input tcvitals records found, then the center
#   time sigma guess will not be modified and this getges file will be read in
#   subsequent PREP processing; if relocation processing continues and the
#   center sigma guess is modified, then ${COM_OBS}/${RUN}.${cycle}.sgesprep_pathname.$tmmark will
#   be removed later in this script {the subsequent PREP step will correctly
#   update ${COM_OBS}/${RUN}.${cycle}.sgesprep_pathname.$tmmark to point to the sgesprep file
#   updated here by the relocation}
#  ----------------------------------------------------------------------------

      if [ $fhr = "0"  ]; then
         "${USHGETGES}/getges.sh" -e "${envir_getges}" -n "${network_getges}" -v "${CDATE10}" \
          -t "${stype}" > "${COM_OBS}/${RUN}.${cycle}.sgesprep_pre-relocate_pathname.${tmmark}"
         cp "${COM_OBS}/${RUN}.${cycle}.sgesprep_pre-relocate_pathname.${tmmark}" \
          "${COM_OBS}/${RUN}.${cycle}.sgesprep_pathname.${tmmark}"
      fi
      set +x
      echo
echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
      echo
      set_trace
   fi
   if [ ! -s $pges ]; then
      set +x
      echo
echo "VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV"
echo "  Get global pressure grib GUESS valid for $fhr hrs relative to center"
echo "                    relocation processing date/time"
echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
      echo
      set_trace
      $USHGETGES/getges.sh -e $envir_getges -n $network_getges \
       -v $CDATE10 -t $ptype $pges
      errges=$?
      if test $errges -ne 0; then
#  problem obtaining global pressure grib guess so exit
         set +x
         echo
         echo "problem obtaining global pressure grib guess valid $fhr hrs \
relative to center relocation date/time;"
         echo "ABNORMAL EXIT!!!!!!!!!!!"
         echo
         set_trace
         if [ -s $DATA/err_exit ]; then
            $DATA/err_exit
         else
############kill -9 ${qid}
            exit 555
         fi
         exit 9
      fi
      set +x
      echo
echo "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
      echo
      set_trace
   fi
done

if [ -f ${tstsp}syndata.tcvitals.$tmmark ]; then
   cp ${tstsp}syndata.tcvitals.$tmmark tcvitals.now
else
   cp "${COM_OBS}/${RUN}.${cycle}.syndata.tcvitals.${tmmark}" "tcvitals.now"
fi


[ -s tcvitals.m12 ]  && cat tcvitals.m12  > VITL
[ -s tcvitals.m6  ]  && cat tcvitals.m6  >> VITL
[ -s tcvitals.now ]  && cat tcvitals.now >> VITL

MP_PULSE=0
MP_TIMEOUT=600
GDATE10=$( ${NDATE:?} -06 ${CDATE10})

#  make unique combined tcvitals file for t-12, t-6 and t+0 -- 
#  if tcvitals does not contains record from current time, skip relocation
#  processing
#  -----------------------------------------------------------------------

grep "$pdy $cyc" VITL
errgrep=$?
> tcvitals
if [ $errgrep -ne 0 ] ; then
   echo "NO TCVITAL RECORDS FOUND FOR $CDATE10 - EXIT TROPICAL CYCLONE \
RELOCATION PROCESSING"

# The existence of ${COM_OBS}/${RUN}.${cycle}.tropcy_relocation_status.$tmmark file will tell the
#  subsequent PREP processing that RELOCATION processing occurred, echo
#  "NO RECORDS to process" into it to further tell PREP processing that records
#   were not processed by relocation and the global sigma guess was NOT
#   modified by tropical cyclone relocation (because no tcvitals records were
#   found)
#   Note:  When tropical cyclone relocation does run to completion and the
#          global sigma guess is modified, the parent script to this will echo
#          "RECORDS PROCESSED" into ${COM_OBS}/${RUN}.${cycle}.tropcy_relocation_status.$tmmark
#          assuming it doesn't already exist (meaning "NO RECORDS to process"
#          was NOT echoed into it here)
# ----------------------------------------------------------------------------

   echo "NO RECORDS to process" > "${COM_OBS}/${RUN}.${cycle}.tropcy_relocation_status.${tmmark}"
   if [[ ! -s "${COM_OBS}/${RUN}.${cycle}.tcvitals.relocate.${tmmark}" ]]; then
      cp "/dev/null" "${COM_OBS}/${RUN}.${cycle}.tcvitals.relocate.${tmmark}"
   fi
else

   cat VITL >>tcvitals
   grep "$pdy $cyc" VITL > tcvitals.now1 


#  create model forecast track location file
#   $DATA/$RUN.$cycle.relocate.model_track.tm00
#  --------------------------------------------

   $USHRELO/tropcy_relocate_extrkr.sh
   err=$?
   if [ $err -ne 0 ]; then

#  problem: script tropcy_relocate_extrkr.sh failed
#  ------------------------------------------------

      set +x
      echo
      echo "$USHRELO/tropcy_relocate_extrkr.sh failed"
      echo "ABNORMAL EXIT!!!!!!!!!!!"
      echo
      set_trace
      if [ -s $DATA/err_exit ]; then
         $DATA/err_exit "Script $USHRELO/tropcy_relocate_extrkr.sh failed"
      else
         exit 555
      fi
      exit 9
   fi

#  relocate model tropical cyclone vortices in ges sigma files
#  -----------------------------------------------------------

   if [ -s fort.*  ]; then
     rm fort.*
   fi

   ln -sf $DATA/tcvitals.now1      fort.11
   ln -sf $DATA/model_track.all    fort.30
   ln -sf $DATA/rel_inform1        fort.62
   ln -sf $DATA/tcvitals.relocate0 fort.65

   i1=20
   i2=53
   for fhr in $( seq -3 $BKGFREQ 3 ) ; do

     if [ $fhr -lt 0 ]; then
       tpref=m$(expr $fhr \* -1)
     elif [ $fhr -eq 0 ]; then
       tpref=es
     elif [ $fhr -gt 0 ]; then
       tpref=p$fhr
     fi

     ln -sf $DATA/sg${tpref}prep          fort.$i1
     ln -sf $DATA/sg${tpref}prep.relocate fort.$i2

     i1=$((i1+1))
     i2=$((i2+BKGFREQ))

   done

#  if LATB or LONB is unset or <= 0, the sigma header values are used
#  ------------------------------------------------------------------

   set +u
   [ -z "$LONB" ] && LONB=0 
   [ -z "$LATB" ] && LATB=0
   set -u

   i1=0
   for gesfhr in $( seq 3 $BKGFREQ 9 ) ; do

     echo $gesfhr $LONB $LATB $BKGFREQ >parm.$i1

     i1=$((i1+1))

   done

#  setup and run the mpi relocation code
#  -------------------------------------

   export MP_EUILIB=us
   export MP_EUIDEVICE=sn_all
   export MP_USE_BULK_XFER=yes
   export RELOX_threads=${RELOX_threads:-16}
   export KMP_STACKSIZE=1024m
   export OMP_NUM_THREADS=$RELOX_threads        
   export MP_TASK_AFFINITY=core:$RELOX_threads

   ${APRNRELOC:-mpirun.lsf} $RELOX >stdo.prints
   errSTATUS=$?
   
#  copy relocation print output here and there
#  -------------------------------------------

   cat $DATA/stdo.prints >> $pgmout
   cat $DATA/stdo.[0-9]* >> $pgmout
   cat $DATA/stdo.prints >> relocate.out
   cat $DATA/stdo.[0-9]* >> relocate.out

#  check for success
#  -----------------

   echo; set_trace
   if [ "$errSTATUS" -gt '0' ]; then
      if [ -s $DATA/err_exit ]; then
         $DATA/err_exit "Script RELOCATE_GES failed"
      else
         exit 555
      fi
      exit 9
   fi

#  further check for success
#  -------------------------

   for fhr in $( seq -3 $BKGFREQ 3 ) ; do

      if [ $fhr -lt 0 ]; then
         tpref=m$(expr $fhr \* -1)
      elif [ $fhr -eq 0 ]; then
         tpref=es
      elif [ $fhr -gt 0 ]; then
         tpref=p$fhr
      fi

      sges=sg${tpref}prep

      if [ -s $sges.relocate ] ; then
         mv $sges.relocate $sges
      else

#  problem: $sges.relocate does not exist
#  --------------------------------------

         if [ -s $DATA/err_exit ]; then
            $DATA/err_exit "The file $sges.relocate does not exist"
         else
            exit 555
         fi
         exit 9
      fi
   done

   if [ -s tcvitals.relocate0 ]; then
      mv tcvitals.relocate0 tcvitals
   else
      >tcvitals
   fi
   rm -f RELOCATE_GES cmd


   cp "rel_inform1" "${COM_OBS}/${RUN}.${cycle}.inform.relocate.${tmmark}"
   cp "tcvitals" "${COM_OBS}/${RUN}.${cycle}.tcvitals.relocate.${tmmark}"
   if [ "$SENDDBN" = "YES" ]; then
       if test "$RUN" = "gdas1"
       then
           "${DBNROOT}/bin/dbn_alert" "MODEL" "GDAS1_TCI" "${job}" "${COM_OBS}/${RUN}.${cycle}.inform.relocate.${tmmark}"
           "${DBNROOT}/bin/dbn_alert" "MODEL" "GDAS1_TCI" "${job}" "${COM_OBS}/${RUN}.${cycle}.tcvitals.relocate.${tmmark}"
       fi
       if test "$RUN" = "gfs"
       then
           "${DBNROOT}/bin/dbn_alert" "MODEL" "GFS_TCI" "${job}" "${COM_OBS}/${RUN}.${cycle}.inform.relocate.${tmmark}"
           "${DBNROOT}/bin/dbn_alert" "MODEL" "GFS_TCI" "${job}" "${COM_OBS}/${RUN}.${cycle}.tcvitals.relocate.${tmmark}"
       fi
   fi

#  --------------------------------------------------------------------------
#   Since relocation processing has ended sucessfully (and the center sigma
#   guess has been modified), remove ${COM_OBS}/${RUN}.${cycle}.sgesprep_pathname.$tmmark (which
#   had earlier had getges center sigma guess pathname written into it - in
#   case of error or no input tcvitals records found) - the subsequent PREP
#   step will correctly update ${COM_OBS}/${RUN}.${cycle}.sgesprep_pathname.$tmmark to point to
#   the sgesprep file updated here by the relocation
#  --------------------------------------------------------------------------

   rm "${COM_OBS}/${RUN}.${cycle}.sgesprep_pathname.${tmmark}"

   echo "TROPICAL CYCLONE RELOCATION PROCESSING SUCCESSFULLY COMPLETED FOR \
$CDATE10"

# end GFDL ges manipulation
# -------------------------

fi


exit 0

