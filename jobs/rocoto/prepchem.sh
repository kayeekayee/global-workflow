#!/bin/ksh -x

###############################################################
## Abstract:
## Create biomass burning emissions for FV3-CHEM
## RUN_ENVIR : runtime environment (emc | nco)
## HOMEgfs   : /full/path/to/workflow
## EXPDIR : /full/path/to/config/files
## CDATE  : current date (YYYYMMDDHH)
## CDUMP  : cycle name (gdas / gfs)
## PDY    : current date (YYYYMMDD)
## cyc    : current cycle (HH)
###############################################################
# Source FV3GFS workflow modules
. $HOMEgfs/ush/load_fv3gfs_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

###############################################################
# Source relevant configs
configs="base prepchem"
for config in $configs; do
    . $EXPDIR/config.${config}
    status=$?
    [[ $status -ne 0 ]] && exit $status
done
###############################################################
export DATA="$RUNDIR/$CDATE/$CDUMP"

[[ ! -d $DATA ]] && mkdir -p $DATA
cd $DATA || exit 10
mkdir -p prep
cd prep

for x in prep_chem_sources_template.inp prep_chem_sources
    do
    # eval $NLN $EMIDIR/$x 
    $NCP ${EMIDIR}${CASE}/$x .
    done
print "in FV3_fim_emission_setup:"
emiss_date="$SYEAR-$SMONTH-$SDAY-$SHOUR" # default value for branch testing      
print "emiss_date: $emiss_date"
print "yr: $SYEAR mm: $SMONTH dd: $SDAY hh: $SHOUR"
# put date in input file
    sed "s/fv3_hh/$SHOUR/g;
         s/fv3_dd/$SDAY/g;
         s/fv3_mm/$SMONTH/g;
         s/fv3_yy/$SYEAR/g" prep_chem_sources_template.inp > prep_chem_sources.inp
    ./prep_chem_sources || fail "ERROR: prep_chem_sources failed."
status=$?
if [ $status -ne 0 ]; then
     echo "error prep_chem_sources failed  $status "
     exit $status
fi

 
for n in $(seq 1 6); do
tiledir=tile${n}
cd $tiledir
    eval $NLN ${CASE}-T-${emiss_date}0000-plume.bin plumestuff.dat
    eval $NLN ${CASE}-T-${emiss_date}0000-OC-bb.bin ebu_oc.dat
    eval $NLN ${CASE}-T-${emiss_date}0000-BC-bb.bin ebu_bc.dat
    eval $NLN ${CASE}-T-${emiss_date}0000-BBURN2-bb.bin ebu_pm_25.dat
    eval $NLN ${CASE}-T-${emiss_date}0000-BBURN3-bb.bin ebu_pm_10.dat
    eval $NLN ${CASE}-T-${emiss_date}0000-SO2-bb.bin ebu_so2.dat
    eval $NLN ${CASE}-T-${emiss_date}0000-SO4-bb.bin ebu_sulf.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-ALD-bb.bin ebu_ald.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-ASH-bb.bin ebu_ash.dat    
    #eval $NLN ${CASE}-T-${emiss_date}0000-CO-bb.bin ebu_co.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-CSL-bb.bin ebu_csl.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-DMS-bb.bin ebu_dms.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-ETH-bb.bin ebu_eth.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-HC3-bb.bin ebu_hc3.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-HC5-bb.bin ebu_hc5.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-HC8-bb.bin ebu_hc8.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-HCHO-bb.bin ebu_hcho.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-ISO-bb.bin ebu_iso.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-KET-bb.bin ebu_ket.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-NH3-bb.bin ebu_nh3.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-NO2-bb.bin ebu_no2.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-NO-bb.bin ebu_no.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-OLI-bb.bin ebu_oli.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-OLT-bb.bin ebu_olt.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-ORA2-bb.bin ebu_ora2.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-TOL-bb.bin ebu_tol.dat
    #eval $NLN ${CASE}-T-${emiss_date}0000-XYL-bb.bin ebu_xyl.dat
    rm *-ab.bin
    rm ${CASE}-T-${emiss_date}0000-ALD-bb.bin
    rm ${CASE}-T-${emiss_date}0000-ASH-bb.bin
    rm ${CASE}-T-${emiss_date}0000-CO-bb.bin
    rm ${CASE}-T-${emiss_date}0000-CSL-bb.bin
    rm ${CASE}-T-${emiss_date}0000-DMS-bb.bin
    rm ${CASE}-T-${emiss_date}0000-ETH-bb.bin
    rm ${CASE}-T-${emiss_date}0000-HC3-bb.bin
    rm ${CASE}-T-${emiss_date}0000-HC5-bb.bin
    rm ${CASE}-T-${emiss_date}0000-HC8-bb.bin
    rm ${CASE}-T-${emiss_date}0000-HCHO-bb.bin
    rm ${CASE}-T-${emiss_date}0000-ISO-bb.bin
    rm ${CASE}-T-${emiss_date}0000-KET-bb.bin
    rm ${CASE}-T-${emiss_date}0000-NH3-bb.bin
    rm ${CASE}-T-${emiss_date}0000-NO2-bb.bin
    rm ${CASE}-T-${emiss_date}0000-NO-bb.bin
    rm ${CASE}-T-${emiss_date}0000-OLI-bb.bin
    rm ${CASE}-T-${emiss_date}0000-OLT-bb.bin
    rm ${CASE}-T-${emiss_date}0000-ORA2-bb.bin
    rm ${CASE}-T-${emiss_date}0000-TOL-bb.bin
    rm ${CASE}-T-${emiss_date}0000-XYL-bb.bin
cd ..
    rm *-g${n}.ctl *-g${n}.vfm *-g${n}.gra
done
  rc=$?
if [ $rc -ne 0 ]; then
     echo "error prepchem $rc "
     exit $rc
fi 


###############################################################

###############################################################
# Exit cleanly

