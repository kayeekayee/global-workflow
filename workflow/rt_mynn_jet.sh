#!/bin/sh
USER=Judy.K.Henderson
GITDIR=/lfs1/BMC/gsd-fv3-test/HFIP/gsl_ufs_rt               ## where your git checkout is located  PLACEHOLDER, change this!
COMROT=$GITDIR/FV3GFSrun                                         ## default COMROT directory
EXPDIR=$GITDIR/FV3GFSwfm                                         ## default EXPDIR directory
ICSDIR=/lfs1/BMC/gsd-fv3-test/rtfim/FV3ICS_L127

PSLOT=rt_v17p8_mynn               ## PLACEHOLDER -- change this
IDATE=2023071300
EDATE=2023071300
RESDET=768               ## 96 192 384 768

### gfs_cyc 1  00Z only;  gfs_cyc 2  00Z and 12Z

./setup_expt.py gfs forecast-only --pslot "${PSLOT}"  --gfs_cyc 1 \
       --idate "${IDATE}" --edate "${EDATE}" --resdetatmos "${RESDET}" \
       --comroot "${COMROT}" --expdir "${EXPDIR}"

