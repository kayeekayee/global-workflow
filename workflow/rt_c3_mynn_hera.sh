USER=role.rtfim
GITDIR=${HOME}/UFS-CAMsuite/                                     ## where your git checkout is located
COMROT=$GITDIR/FV3GFSrun                                         ## default COMROT directory
EXPDIR=$GITDIR/FV3GFSwfm                                         ## default EXPDIR directory
ICSDIR=/scratch1/BMC/gsd-fv3/rtruns/FV3ICS_L127

PSLOT=rt_v17p8_ugwpv1_c3_mynn
IDATE=2024011400
EDATE=2024011400
RESDET=768               ## 96 192 384 768

### gfs_cyc 1  00Z only;  gfs_cyc 2  00Z and 12Z

./setup_expt.py gfs forecast-only --pslot "${PSLOT}"  --gfs_cyc 1 \
       --idate "${IDATE}" --edate "${EDATE}" --resdetatmos "${RESDET}" \
       --comroot "${COMROT}" --expdir "${EXPDIR}"

