USER=Judy.K.Henderson
GITDIR=/home/Judy.K.Henderson/scratch/issue178           ## where your git checkout is located
COMROT=$GITDIR/FV3GFSrun                                         ## default COMROT directory
EXPDIR=$GITDIR/FV3GFSwfm                                         ## default EXPDIR directory

#    ICSDIR is assumed to be under $COMROT/FV3ICS
#cp $GITDIR/parm/config/config.base.emc.dyn $GITDIR/parm/config/config.base

PSLOT=test_coldics_l127
IDATE=2021040300
EDATE=2021040300
RESDET=768               ## 96 192 384 768
startics=cold

### gfs_cyc 1  00Z only;  gfs_cyc 2  00Z and 12Z
###   default startics=cold

./setup_expt_fcstonly_gsd.py --pslot $PSLOT  \
       --gfs_cyc 1 --idate $IDATE --edate $EDATE \
       --configdir $GITDIR/parm/config \
       --start=$startics --res $RESDET --comrot $COMROT --expdir $EXPDIR

#for running chgres, forecast, and post
./setup_workflow_fcstonly.py --expdir $EXPDIR/$PSLOT
