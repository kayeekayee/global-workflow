USER=Judy.K.Henderson
COMROT=/scratch4/BMC/fim/NCEPDEV/global/noscrub/$USER/fv3gfs/comrot ## default COMROT directory
EXPDIR=/scratch4/BMC/fim/NCEPDEV/global/save/$USER/fv3gfs/expdir    ## default EXPDIR directory
PTMP=/scratch4/BMC/fim/NCEPDEV/stmp4/$USER                          ## default PTMP directory
STMP=/scratch4/BMC/fim/NCEPDEV/stmp3/$USER                          ## default STMP directory
GITDIR=/home/Judy.K.Henderson/scratch/git_local/gerrit_master_17mar18_a69828b
#ICSDIR=/scratch4/BMC/rtfim/rtruns/FV3GFS/FV3ICS/
#    ICSDIR is assumed to be under $COMROT/FV3ICS


PSLOT=exp_ff
IDATE=2018030100
EDATE=2018030100

./setup_expt_fcstonly.py --pslot $PSLOT  \
       --gfs_cyc 2 --idate $IDATE --edate $EDATE \
       --configdir $GITDIR/parm/config \
       --res 384 --comrot $COMROT --expdir $EXPDIR


   #add resolution parameter if running other than C192
#       --res 768 --comrot $COMROT --expdir $EXPDIR


#for running chgres, forecast, and post 
./setup_workflow_fcstonly_gsd.py --expdir $EXPDIR/$PSLOT

