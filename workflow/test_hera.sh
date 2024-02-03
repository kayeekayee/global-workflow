USER=Judy.K.Henderson
GITDIR=/scratch1/BMC/gsd-fv3-dev/Judy.K.Henderson/test/gsl_ufs_rt         ## where your git checkout is located
COMROT=$GITDIR/FV3GFSrun/rt_v17p8_ugwpv1_mynn                    ## default COMROT directory
EXPDIR=$GITDIR/FV3GFSwfm/rt_v17p8_ugwpv1_mynn                    ## default EXPDIR directory
ICSDIR=/scratch1/BMC/gsd-fv3/rtruns/FV3ICS_L127

PSLOT=test_hera
IDATE=2022110900
EDATE=2022110900
RESDET=768               ## 96 192 384 768

### gfs_cyc 1  00Z only;  gfs_cyc 2  00Z and 12Z

./setup_expt.py gfs forecast-only --pslot $PSLOT  --gfs_cyc 1 \
       --idate $IDATE --edate $EDATE --resdet $RESDET \
       --comrot $COMROT --expdir $EXPDIR

