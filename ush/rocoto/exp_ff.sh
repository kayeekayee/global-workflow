USER=Judy.K.Henderson
GITDIR=/scratch2/BMC/gsd-fv3-dev/Judy.K.Henderson/test/rt_fv3chem_v16
COMROT=${GITDIR}/FV3GFSrun                                          ## default COMROT directory
EXPDIR=${GITDIR}/FV3GFSwfm                                          ## default EXPDIR directory
PTMP=/scratch2/BMC/gsd-fv3-dev/NCEPDEV/stmp4/$USER                  ## default PTMP directory
STMP=/scratch2/BMC/gsd-fv3-dev/NCEPDEV/stmp3/$USER                  ## default STMP directory

#    ICSDIR is assumed to be under $COMROT/FV3ICS
#         create link $COMROT/FV3ICS to point to /scratch4/BMC/rtfim/rtruns/FV3GFS/FV3ICS


PSLOT=testv16
IDATE=2019032000
EDATE=2019032000
RESDET=384               ## 96 192 384 768

./setup_expt_fcstonly.py --pslot $PSLOT  \
       --gfs_cyc 2 --idate $IDATE --edate $EDATE \
       --configdir $GITDIR/parm/config \
       --res $RESDET --comrot $COMROT --expdir $EXPDIR

#for running chgres, forecast, and post 
./setup_workflow_fcstonly_gsd.py --expdir $EXPDIR/$PSLOT

