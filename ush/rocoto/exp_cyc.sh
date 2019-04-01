USER=Judy.K.Henderson
COMROT=/scratch4/BMC/fim/NCEPDEV/global/noscrub/$USER/fv3gfs/comrot ## default COMROT directory
EXPDIR=/scratch4/BMC/fim/NCEPDEV/global/save/$USER/fv3gfs/expdir    ## default EXPDIR directory
PTMP=/scratch4/BMC/fim/NCEPDEV/stmp4/$USER                          ## default PTMP directory
STMP=/scratch4/BMC/fim/NCEPDEV/stmp3/$USER                          ## default STMP directory
GITDIR=/home/Judy.K.Henderson/scratch/git_local/gerrit_master_15Dec18_cc32f99
ICSDIR=/scratch4/BMC/rtfim/rtruns/FV3ICS/
#ICSDIR=/scratch4/NCEPDEV/da/noscrub/Rahul.Mahajan/ICS


PSLOT=exp_cyc
IDATE=2017073118
EDATE=2017080100

./setup_expt.py --pslot $PSLOT  \
       --idate $IDATE --edate $EDATE \
       --configdir $GITDIR/parm/config \
       --icsdir $ICSDIR --comrot $COMROT --expdir $EXPDIR

#for running chgres, forecast, and post 
./setup_workflow.py --expdir $EXPDIR/$PSLOT

