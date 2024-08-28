#! /usr/bin/env bash

source "${HOMEgfs}/ush/preamble.sh"

##############################################
# Begin JOB SPECIFIC work
##############################################

# ICS are restarts and always lag INC by $assim_freq hours
ARCHINC_CYC=${ARCH_CYC}
ARCHICS_CYC=$((ARCH_CYC-assim_freq))
if [[ "${ARCHICS_CYC}" -lt 0 ]]; then
    ARCHICS_CYC=$((ARCHICS_CYC+24))
fi

# CURRENT CYCLE
APREFIX="${RUN}.t${cyc}z."

# Realtime parallels run GFS MOS on 1 day delay
# If realtime parallel, back up CDATE_MOS one day
# Ignore possible spelling error (nothing is misspelled)
# shellcheck disable=SC2153
CDATE_MOS=${PDY}${cyc}
if [[ "${REALTIME}" = "YES" ]]; then
    CDATE_MOS=$(${NDATE} -24 "${PDY}${cyc}")
fi
PDY_MOS="${CDATE_MOS:0:8}"

###############################################################
# Archive online for verification and diagnostics
###############################################################
#JKHsource "${HOMEgfs}/ush/file_utils.sh"
#JKH
#JKH[[ ! -d ${ARCDIR} ]] && mkdir -p "${ARCDIR}"
#JKHnb_copy "${COM_ATMOS_ANALYSIS}/${APREFIX}gsistat" "${ARCDIR}/gsistat.${RUN}.${PDY}${cyc}"
#JKHif [[ ${DO_AERO} = "YES" ]]; then
#JKH   nb_copy "${COM_CHEM_ANALYSIS}/${APREFIX}aerostat" "${ARCDIR}/aerostat.${RUN}.${PDY}${cyc}"
#JKHfi
#JKHnb_copy "${COM_ATMOS_GRIB_1p00}/${APREFIX}pgrb2.1p00.anl" "${ARCDIR}/pgbanl.${RUN}.${PDY}${cyc}.grib2"
#JKH
#JKH# Archive 1 degree forecast GRIB2 files for verification
#JKHif [[ "${RUN}" == "gfs" ]]; then
#JKH    fhmax=${FHMAX_GFS}
#JKH    fhr=0
#JKH    while [ "${fhr}" -le "${fhmax}" ]; do
#JKH        fhr2=$(printf %02i "${fhr}")
#JKH        fhr3=$(printf %03i "${fhr}")
#JKH        nb_copy "${COM_ATMOS_GRIB_1p00}/${APREFIX}pgrb2.1p00.f${fhr3}" "${ARCDIR}/pgbf${fhr2}.${RUN}.${PDY}${cyc}.grib2"
#JKH        fhr=$((10#${fhr} + 10#${FHOUT_GFS} ))
#JKH    done
#JKHfi
#JKHif [[ "${RUN}" == "gdas" ]]; then
#JKH    flist="000 003 006 009"
#JKH    for fhr in ${flist}; do
#JKH        fname="${COM_ATMOS_GRIB_1p00}/${APREFIX}pgrb2.1p00.f${fhr}"
#JKH        # TODO Shouldn't the archived files also use three-digit tags?
#JKH        fhr2=$(printf %02i $((10#${fhr})))
#JKH        nb_copy "${fname}" "${ARCDIR}/pgbf${fhr2}.${RUN}.${PDY}${cyc}.grib2"
#JKH    done
#JKHfi
#JKH
#JKHif [[ -s "${COM_ATMOS_TRACK}/avno.t${cyc}z.cyclone.trackatcfunix" ]]; then
#JKH    # shellcheck disable=2153
#JKH    PSLOT4=${PSLOT:0:4}
#JKH    # shellcheck disable=
#JKH    PSLOT4=${PSLOT4^^}
#JKH    sed "s:AVNO:${PSLOT4}:g" < "${COM_ATMOS_TRACK}/avno.t${cyc}z.cyclone.trackatcfunix" \
#JKH        > "${ARCDIR}/atcfunix.${RUN}.${PDY}${cyc}"
#JKH    sed "s:AVNO:${PSLOT4}:g" < "${COM_ATMOS_TRACK}/avnop.t${cyc}z.cyclone.trackatcfunix" \
#JKH        > "${ARCDIR}/atcfunixp.${RUN}.${PDY}${cyc}"
#JKHfi
#JKH
#JKHif [[ "${RUN}" == "gdas" ]] && [[ -s "${COM_ATMOS_TRACK}/gdas.t${cyc}z.cyclone.trackatcfunix" ]]; then
#JKH    # shellcheck disable=2153
#JKH    PSLOT4=${PSLOT:0:4}
#JKH    # shellcheck disable=
#JKH    PSLOT4=${PSLOT4^^}
#JKH    sed "s:AVNO:${PSLOT4}:g" < "${COM_ATMOS_TRACK}/gdas.t${cyc}z.cyclone.trackatcfunix" \
#JKH        > "${ARCDIR}/atcfunix.${RUN}.${PDY}${cyc}"
#JKH    sed "s:AVNO:${PSLOT4}:g" < "${COM_ATMOS_TRACK}/gdasp.t${cyc}z.cyclone.trackatcfunix" \
#JKH        > "${ARCDIR}/atcfunixp.${RUN}.${PDY}${cyc}"
#JKHfi
#JKH
#JKHif [ "${RUN}" = "gfs" ]; then
#JKH    nb_copy "${COM_ATMOS_GENESIS}/storms.gfso.atcf_gen.${PDY}${cyc}"      "${ARCDIR}/."
#JKH    nb_copy "${COM_ATMOS_GENESIS}/storms.gfso.atcf_gen.altg.${PDY}${cyc}" "${ARCDIR}/."
#JKH    nb_copy "${COM_ATMOS_TRACK}/trak.gfso.atcfunix.${PDY}${cyc}"          "${ARCDIR}/."
#JKH    nb_copy "${COM_ATMOS_TRACK}/trak.gfso.atcfunix.altg.${PDY}${cyc}"     "${ARCDIR}/."
#JKH
#JKH    mkdir -p "${ARCDIR}/tracker.${PDY}${cyc}/${RUN}"
#JKH    blist="epac natl"
#JKH    for basin in ${blist}; do
#JKH        if [[ -f ${basin} ]]; then
#JKH            cp -rp "${COM_ATMOS_TRACK}/${basin}" "${ARCDIR}/tracker.${PDY}${cyc}/${RUN}"
#JKH        fi
#JKH    done
#JKHfi
#JKH
#JKH# Archive required gaussian gfs forecast files for Fit2Obs
#JKHif [[ "${RUN}" == "gfs" ]] && [[ "${FITSARC}" = "YES" ]]; then
#JKH    VFYARC=${VFYARC:-${ROTDIR}/vrfyarch}
#JKH    [[ ! -d ${VFYARC} ]] && mkdir -p "${VFYARC}"
#JKH    mkdir -p "${VFYARC}/${RUN}.${PDY}/${cyc}"
#JKH    prefix="${RUN}.t${cyc}z"
#JKH    fhmax=${FHMAX_FITS:-${FHMAX_GFS}}
#JKH    fhr=0
#JKH    while [[ ${fhr} -le ${fhmax} ]]; do
#JKH        fhr3=$(printf %03i "${fhr}")
#JKH        sfcfile="${COM_ATMOS_HISTORY}/${prefix}.sfcf${fhr3}.nc"
#JKH        sigfile="${COM_ATMOS_HISTORY}/${prefix}.atmf${fhr3}.nc"
#JKH        nb_copy "${sfcfile}" "${VFYARC}/${RUN}.${PDY}/${cyc}/"
#JKH        nb_copy "${sigfile}" "${VFYARC}/${RUN}.${PDY}/${cyc}/"
#JKH        (( fhr = 10#${fhr} + 6 ))
#JKH    done
#JKHfi


###############################################################
# Archive data either to HPSS or locally
if [[ ${HPSSARCH} = "YES" || ${LOCALARCH} = "YES" ]]; then
###############################################################

    # --set the archiving command and create local directories, if necessary
    TARCMD="htar"
    HSICMD="hsi"
    if [[ ${LOCALARCH} = "YES" ]]; then
       TARCMD="tar"
       HSICMD=''
       [[ ! -d "${ATARDIR}/${PDY}${cyc}" ]] && mkdir -p "${ATARDIR}/${PDY}${cyc}"
       [[ ! -d "${ATARDIR}/${CDATE_MOS}" ]] && [[ -d "${ROTDIR}/gfsmos.${PDY_MOS}" ]] && [[ "${cyc}" -eq 18 ]] && mkdir -p "${ATARDIR}/${CDATE_MOS}"
    fi

    #--determine when to save ICs for warm start and forecast-only runs
    SAVEWARMICA="NO"
    SAVEWARMICB="NO"
    SAVEFCSTIC="NO"
    firstday=$(${NDATE} +24 "${SDATE}")
    mm="${PDY:2:2}"
    dd="${PDY:4:2}"
    # TODO: This math yields multiple dates sharing the same nday
    nday=$(( (10#${mm}-1)*30+10#${dd} ))
    mod=$((nday % ARCH_WARMICFREQ))
    if [[ "${PDY}${cyc}" -eq "${firstday}" ]] && [[ "${cyc}" -eq "${ARCHINC_CYC}" ]]; then SAVEWARMICA="YES" ; fi
    if [[ "${PDY}${cyc}" -eq "${firstday}" ]] && [[ "${cyc}" -eq "${ARCHICS_CYC}" ]]; then SAVEWARMICB="YES" ; fi
    if [[ "${mod}" -eq 0 ]] && [[ "${cyc}" -eq "${ARCHINC_CYC}" ]]; then SAVEWARMICA="YES" ; fi
    if [[ "${mod}" -eq 0 ]] && [[ "${cyc}" -eq "${ARCHICS_CYC}" ]]; then SAVEWARMICB="YES" ; fi

    if [[ "${ARCHICS_CYC}" -eq 18 ]]; then
        nday1=$((nday+1))
        mod1=$((nday1 % ARCH_WARMICFREQ))
        if [[ "${mod1}" -eq 0 ]] && [[ "${cyc}" -eq "${ARCHICS_CYC}" ]] ; then SAVEWARMICB="YES" ; fi
        if [[ "${mod1}" -ne 0 ]] && [[ "${cyc}" -eq "${ARCHICS_CYC}" ]] ; then SAVEWARMICB="NO" ; fi
        if [[ "${PDY}${cyc}" -eq "${SDATE}" ]] && [[ "${cyc}" -eq "${ARCHICS_CYC}" ]] ; then SAVEWARMICB="YES" ; fi
    fi

    mod=$((nday % ARCH_FCSTICFREQ))
    if [[ "${mod}" -eq 0 ]] || [[ "${PDY}${cyc}" -eq "${firstday}" ]]; then SAVEFCSTIC="YES" ; fi

    cd "${DATA}" || exit 2

    "${HOMEgfs}/ush/hpssarch_gen.sh" "${RUN}"
    status=$?
    if [[ "${status}" -ne 0  ]]; then
        echo "${HOMEgfs}/ush/hpssarch_gen.sh ${RUN} failed, ABORT!"
        exit "${status}"
    fi

    cd "${ROTDIR}" || exit 2

    if [[ "${RUN}" = "gfs" ]]; then

        targrp_list="gfs_pgrb2"

        if [[ "${ARCH_GAUSSIAN:-"NO"}" = "YES" ]]; then
            targrp_list="${targrp_list} gfs_nc"
        fi

        #for initial conditions
        if [[ "${SAVEFCSTIC}" = "YES" ]]; then
            targrp_list="${targrp_list} gfs_ics"
        fi

    fi

    # Turn on extended globbing options
    yyyy="${PDY:0:4}"
    shopt -s extglob
    for targrp in ${targrp_list}; do
        set +e

        # Test whether gdas.tar or gdas_restarta.tar will have rstprod data
        has_rstprod="NO"
        case ${targrp} in
            'gdas'|'gdas_restarta')
                # Test for rstprod in each archived file
                while IFS= read -r file; do
                    if [[ -f ${file} ]]; then
                        group=$( stat -c "%G" "${file}" )
                        if [[ "${group}" == "rstprod" ]]; then
                            has_rstprod="YES"
                            break
                        fi
                    fi
                done < "${DATA}/${targrp}.txt"

                ;;
            *) ;;
        esac

        # Create the tarball
        tar_fl="${ATARDIR}/${yyyy}/${PDY}${cyc}/${targrp}.tar"
        ${TARCMD} -P -cvf "${tar_fl}" $(cat "${DATA}/${targrp}.txt")
        status=$?

        # Change group to rstprod if it was found even if htar/tar failed in case of partial creation
        if [[ "${has_rstprod}" == "YES" ]]; then
            ${HSICMD} chgrp rstprod "${tar_fl}"
            stat_chgrp=$?
            ${HSICMD} chmod 640 "${tar_fl}"
            stat_chgrp=$((stat_chgrp+$?))
            if [[ "${stat_chgrp}" -gt 0 ]]; then
                echo "FATAL ERROR: Unable to properly restrict ${tar_fl}!"
                echo "Attempting to delete ${tar_fl}"
                ${HSICMD} rm "${tar_fl}"
                echo "Please verify that ${tar_fl} was deleted!"
                exit "${stat_chgrp}"
            fi
        fi

        # For safety, test if the htar/tar command failed after changing groups
        if [[ "${status}" -ne 0 ]] && [[ "${PDY}${cyc}" -ge "${firstday}" ]]; then
            echo "FATAL ERROR: ${TARCMD} ${tar_fl} failed"
            exit "${status}"
        fi
        set_strict
    done
    # Turn extended globbing back off
    shopt -u extglob

###############################################################
fi  ##end of HPSS archive
###############################################################

