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
module list
for x in prep_chem_sources_template.inp prep_chem_sources
    do
    # eval $NLN $EMIDIR/$x 
    $NCP ${EMIDIR}${CASE}/$x .
    done
print "in FV3_fim_emission_setup:"
emiss_date="$SYEAR-$SMONTH-$SDAY-$SHOUR" # default value for branch testing      
print "emiss_date: $emiss_date"
print "yr: $SYEAR mm: $SMONTH dd: $SDAY hh: $SHOUR"

if [ $EMITYPE -eq 1 ]; then
# put date in input file
    sed "s/fv3_hh/$SHOUR/g;
         s/fv3_dd/$SDAY/g;
         s/fv3_mm/$SMONTH/g;
         s/fv3_yy/$SYEAR/g" prep_chem_sources_template.inp > prep_chem_sources.inp
. $MODULESHOME/init/sh 2>/dev/null
module list
module purge
module list
module load intel/14.0.2
module load szip/2.1
module load hdf5/1.8.14
module load netcdf/4.3.0
module list
    ./prep_chem_sources || fail "ERROR: prep_chem_sources failed."
status=$?
if [ $status -ne 0 ]; then
     echo "error prep_chem_sources failed  $status "
     exit $status
fi
fi
 
for n in $(seq 1 6); do
tiledir=tile${n}
mkdir -p $tiledir
cd $tiledir
    if [ $EMITYPE -eq 1 ]; then
    eval $NLN ${CASE}-T-${emiss_date}0000-BBURN3-bb.bin ebu_pm_10.dat
    eval $NLN ${CASE}-T-${emiss_date}0000-SO4-bb.bin ebu_sulf.dat
    eval $NLN ${CASE}-T-${emiss_date}0000-plume.bin plumestuff.dat
    eval $NLN ${CASE}-T-${emiss_date}0000-OC-bb.bin ebu_oc.dat
    eval $NLN ${CASE}-T-${emiss_date}0000-BC-bb.bin ebu_bc.dat
    eval $NLN ${CASE}-T-${emiss_date}0000-BBURN2-bb.bin ebu_pm_25.dat
    eval $NLN ${CASE}-T-${emiss_date}0000-SO2-bb.bin ebu_so2.dat
    fi
    if [ $EMITYPE -eq 2 ]; then
        emiss_date1="$SYEAR$SMONTH$SDAY" # default value for branch testing      
        print "emiss_date: $emiss_date1"
        mkdir -p $DIRGB/$emiss_date1
        if [[ -f $PUBEMI/GBBEPx.emis_BC.003.${emiss_date1}.FV3.${CASE}Grid.${tiledir}.bin ]]; then
          $NCP $PUBEMI/*${emiss_date1}.*.bin $DIRGB/$emiss_date1/
        else
          $NCP $ARCEMI/*${emiss_date1}.*.bin $DIRGB/$emiss_date1/
        fi
        eval $NLN $DIRGB/${emiss_date1}/GBBEPx.emis_BC.003.${emiss_date1}.FV3.${CASE}Grid.$tiledir.bin  ebu_bc.dat
        eval $NLN $DIRGB/${emiss_date1}/GBBEPx.emis_OC.003.${emiss_date1}.FV3.${CASE}Grid.$tiledir.bin  ebu_oc.dat
        eval $NLN $DIRGB/${emiss_date1}/GBBEPx.emis_SO2.003.${emiss_date1}.FV3.${CASE}Grid.$tiledir.bin  ebu_so2.dat
        eval $NLN $DIRGB/${emiss_date1}/GBBEPx.emis_PM2.5.003.${emiss_date1}.FV3.${CASE}Grid.$tiledir.bin  ebu_pm_25.dat
        eval $NLN $DIRGB/${emiss_date1}/GBBEPx.FRP.003.${emiss_date1}.FV3.${CASE}Grid.$tiledir.bin  plumefrp.dat
        cd ..
    fi
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
    if [ $EMITYPE -eq 1 ]; then 
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
    fi
done
rc=$?
if [ $rc -ne 0 ]; then
     echo "error prepchem $rc "
     exit $rc
fi 


###############################################################

###############################################################
# Exit cleanly

