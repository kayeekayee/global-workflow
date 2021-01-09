USER=Judy.K.Henderson
PTMP=/scratch2/BMC/gsd-fv3-dev/NCEPDEV/stmp3/${USER}                     ## default PTMP directory
STMP=/scratch2/BMC/gsd-fv3-dev/NCEPDEV/stmp4/${USER}                     ## default STMP directory
GITDIR=/scratch2/BMC/gsd-fv3-dev/Judy.K.Henderson/test/update_jet        ## where your git checkout is located
COMROT=${GITDIR}/FV3GFSrun                                               ## default COMROT directory
EXPDIR=${GITDIR}/FV3GFSwfm                                               ## default EXPDIR directory

PSLOT=gsdnoahcyc384
IDATE=2020081918
EDATE=2020082100
RESDET=384
RESENS=192
NENS=40
HPSS_PROJECT=fim

ln -fs ${GITDIR}/parm/config/config.base.emc.dyn_hera ${GITDIR}/parm/config/config.base.emc.dyn
ln -fs ${GITDIR}/parm/config/config.base.emc.dyn_hera ${GITDIR}/parm/config/config.base
ln -fs ${GITDIR}/parm/config/config.postsnd_hera ${GITDIR}/parm/config/config.postsnd

### note default RESDET=384 RESENS=192 NENS=20  CCPP_SUITE=FV3_GFS_v16beta
###./setup_expt.py --pslot $PSLOT --configdir $CONFIGDIR --idate $IDATE --edate $EDATE --comrot $COMROT --expdir $EXPDIR [ --icsdir $ICSDIR --resdet $RESDET --resens $RESENS --nens $NENS --gfs_cyc $GFS_CYC ]

./setup_expt_gsd.py --pslot $PSLOT  \
       --idate $IDATE --edate $EDATE \
       --configdir $GITDIR/parm/config \
       --resdet=$RESDET --resens $RESENS \
       --nens $NENS --comrot $COMROT --expdir $EXPDIR

#for running chgres, forecast, and post 
./setup_workflow.py --expdir $EXPDIR/$PSLOT

