#!/bin/sh
USER=kayee.wong
GITDIR=/scratch2/BMC/gsd-fv3-dev/KaYee.Wong/global/2025FebMerge/test/gsl_ufs_dev
COMROT=${GITDIR}/FV3GFSrun                                         ## default COMROT directory
EXPDIR=${GITDIR}/FV3GFSwfm                                         ## default EXPDIR directory
#ICSDIR=/scratch1/BMC/gsd-fv3/rtruns/FV3ICS_L127

PSLOT=mynn
IDATE=2025030100
EDATE=2025030100
RESDET=768               ## 96 192 384 768

### gfs_cyc 1  00Z only;  gfs_cyc 2  00Z and 12Z

./setup_expt.py gfs forecast-only --pslot "${PSLOT}" --interval 24 \
       --idate "${IDATE}" --edate "${EDATE}" --resdetatmos "${RESDET}" \
       --comroot "${COMROT}" --expdir "${EXPDIR}"

